package Game::AI::Simple;
use warnings;
use strict;

use Game;
use Game::Model::Map;
use Game::Model::Game;
use Game::Environment qw(:std :db :config global_user);

#use base 'Game::AI::Base';
use base 'Game::AI::Random';

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new(@_);
    $self->{prioriry} = Game::AI::Simple::PriorityTables->new({ owner => $self });
    $self
}

sub load_map {
    my ($s, $map_id) = @_;
    $_ = $s->cmd_get_map_info();
    $s->{obj}{map} = Game::Model::Map->construct_from_state($_->{mapInfo});
}

sub load_game {
    my ($s, $game_state, $map) = @_;
    $game_state //= $s->last_game_state();
    $map //= $s->{obj}{map};

    my $game = Game::Model::Game->new(gameName  => 'game obj',
                                      map => $map);
    # global_user should be set before calling of game->load_state
    my $dummy_user = Game::Model::User->new(username => 'dummy-user',
                                            password => 'dummy-password',
                                            activeGame => $game);
    global_user($dummy_user);
    $game->load_state($game_state);
    global_user($game->activePlayer());
    $s->{obj}{game} = $game
}

sub join_game_hook {
    my ($s) = @_;
    db_lazy_replace();
    $s->load_map();
    # for error description feature
    Game::Environment::init();
}

sub leave_game_hook {  delete shift->{obj} }

sub before_act_hook {
    my ($s, $act) = @_;
    if ($act ~~ [qw(decline_or_conquer conquer select_race)]) {
        $s->load_game()
    }
}

sub act_select_race {
    my ($s) = @_;
    my $packs = $s->last_game_state()->{visibleTokenBadges};
    my $n = $s->{prioriry}->select_race($packs);
    $s->cmd_select_race($n)
}

sub act_decline_or_conquer {
    my ($s) = @_;
    my $game = global_game();
    if (rand(400) < ($game->activePlayer()->tokensInHand() - 20)**2) {
        $s->send_cmd(action => 'decline');
    } else {
        $s->act_conquer();
    }
}

sub _determine_possible_moves {
    my ($s) = @_;
    my $race = $s->{obj}{game}->activePlayer()->activeRace();
    my $regions = $s->{obj}{map}->regions();
    my $check = sub {
        my ($reg) = @_;
        eval { $race->check_is_move_possible($reg) };
        if ($@) {
            if (ref($@) eq 'Game::Exception::EarlyResponse') {
                return 0
            } else {
                die $@
            }
        }
        if ($reg->{owner} && $reg->{owner} eq global_user()) {
            return 0;
        }
        return 1
    };
    [ grep { $check->($_) } @$regions ];
}

sub act_conquer {
    my ($s) = @_;
    my $regions = $s->_determine_possible_moves();

    unless (@$regions) {
        return $s->execute_action('redeploy')
    }

    my $race = global_user()->activeRace();
    my $reg_strength = [ map { $race->_calculate_land_strength($_) } @$regions ];

    my $reg_id = $s->{prioriry}->conquer({ regions => $regions,
                                           reg_strength => $reg_strength,
                                           race => $race->race_name(),
                                           power => $race->power_name() });
    $s->cmd_conquer($reg_id)
}

#sub act_defend {
#    my ($s) = @_;
#    ...
#}

#sub act_redeploy {
#    my ($s) = @_;
#    ...
#}

sub act_redeployed {
    my ($s) = @_;
    ...
}


1;

package Game::AI::Simple::PriorityTables;
use warnings;
use strict;

use base 'Game::AI::Log';


our %races = (
    amazons   => { weight => 3 },
    dwarves   => { weight => 0,
                   like_land => 'mine' },
    elves     => { weight => 2 },
    giants    => { weight => 1 },
    halflings => { weight => 2 },
    humans    => { weight => 1,
                   like_land => 'farmland'},
    orcs      => { weight => 1 },
    ratmen    => { weight => 3 },
    skeletons => { weight => 3 },
    sorcerers => { weight => 3 },
    tritons   => { weight => 2,
                   like_land => 'coast' },
    trolls    => { weight => 1 },
    wizards   => { weight => 1,
                   like_land => 'magic' },
);

our %powers = (
    alchemist    => { weight => 1 },
    berserk      => { weight => 3 },
    bivouacking  => { weight => 3 },
    commando     => { weight => 3 },
    diplomat     => { weight => 3 },
    dragonmaster => { weight => 3 },
    flying       => { weight => 2 },
    forest       => { weight => 1,
                      like_land => 'forest' },
    fortified    => { weight => 2 },
    heroic       => { weight => 3 },
    hill         => { weight => 1,
                      like_land => 'hill' },
    merchant     => { weight => 1 },
    mounted      => { weight => 1,
                      like_land => ['farmland', 'hill'] },
    pillaging    => { weight => 1 },
    seafaring    => { weight => 2,
                      like_land => ['sea'] },
    stout        => { weight => 2 },
    swamp        => { weight => 1,
                      like_land => ['swamp'] },
    underworld   => { weight => 1,
                      like_land => ['cavern'] },
    wealthy      => { weight => 1 },
);

sub new {
    my ($class, $params) = @_;
    unless (defined $params && defined $params->{owner}) {
        die 'owner field is required'
    }
    my $self = $class->SUPER::new(@_);
    $self->{owner} = $params->{owner};
    $self
}

sub owner_game { shift->{owner}{obj}{game} }

sub conquer {
    my ($s, $params) = @_;
    my $reg_weight = [ map { { id => $_->{regionId}} } @{$params->{regions}} ];

    for (0 .. $#{$params->{reg_strength}}) {
        $reg_weight->[$_]{weight} = -$params->{reg_strength}[$_]
    }

    $s->_select_best($reg_weight)->{id};
}

sub select_race {
    my ($self, $packs) = @_;
    my $res = [];

    for (0 .. $#$packs) {
        my $pack = $packs->[$_];
        $res->[$_] = { id => $_ };
        $res->[$_]{weight} = $races{ lc $pack->{raceName} }->{weight};
        $res->[$_]{weight} += $powers{ lc  $pack->{specialPowerName} }->{weight};
    }
    $self->_select_best($res)->{id};
}

sub decline_or_conquer {
    ...
}

sub _select_best {
    my $self = shift;
    my $array = @_ > 1 ? \@_ : $_[0];
    my $max = [shift @$array];
    for (@$array) {
        if ($_->{weight} > $max->[0]{weight}) {
            $max = [$_];
        } elsif ($_->{weight} == $max->[0]{weight}) {
            push @$max, $_
        }
    }
    $max->[int( rand(@$max) )]
}

sub _select_linear_weight {
    ...
}

sub _select_exponential_weight {
    ...
}

1;
