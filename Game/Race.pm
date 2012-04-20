package Game::Race;
use Moose;

use Game::Environment qw(:std :db :response);
use List::Util qw( sum );


has 'inDecline' => ( isa => 'Bool',
                     is => 'rw',
                     default => 0 );

has 'tokenBadgeId' => ( isa => 'Int',
                        is => 'rw',
                        default => -1 );

# TODO:
sub total_tokens_num {
    my ($self) = @_;
#    ...
#    $self->max_tokens() => _power_max_tokens();
    0
}

sub extract_state {
    my ($self) = @_;
    my %h = %$self;
    \%h
}

sub before_first_attack_hook { }

sub load_state {
    my ($self, $state) = @_;
    assert(ref($state) eq 'HASH', 'badRaceState');
    for my $k (keys %$state) {
        eval {
            $self->$k($state->{$k})
        };
        assert(!$@, 'badRaceState');
    }
}

sub _check_land_type {
    my ($self, $reg) = @_;
    if ('sea' ~~ $reg->landDescription()) {
        early_response_json({result => 'badRegion'})
    }
}

sub _check_land_ownership {
    my ($self, $reg) = @_;
    if ($reg->owner() && !$reg->inDecline() &&
        $reg->owner() eq global_user())
    {
        early_response_json({result => 'badRegion'})
    }
}

sub _check_land_immune {
    my ($self, $reg) = @_;
    for ('dragon', 'hero', 'hole') {
        if ($_ ~~ $reg->extraItems()) {
            early_response_json({result => 'regionIsImmune'});
        }
    }
}

sub _regions_are_adjacent {
    my ($self, $r1, $r2) = @_;
    $r1->regionId() ~~ $r2->adjacent() || $r2->regionId() ~~ $r1->adjacent();
}

sub _region_is_adjacent_with_our {
    my ($self, $reg, $should_be_active) = @_;
    $should_be_active //= 0;
    my $map = global_game()->map();
    for (@{$reg->adjacent()}) {
        my $reg = $map->get_region($_);
        unless ($should_be_active && $reg->inDecline()) {
            my $owner = $reg->owner();
            return 1 if $owner && $owner eq global_user();
        }
    }
    0
}

sub _check_land_reachability {
    my ($self, $reg) = @_;
    my $canMove = $self->_region_is_adjacent_with_our($reg, 'active');
    if (!$canMove && !global_user()->have_owned_active_regions()) {
        for (@{$reg->landDescription()}) {
            $canMove ||=  $_ ~~ ['border', 'coast']
        }
    }
    unless ($canMove) {
        early_response_json({result => 'badRegion'});
    }
}

sub check_is_move_possible {
    my ($self, $reg) = @_;
    $self->_check_land_type($reg);
    $self->_check_land_ownership($reg);
    $self->_check_land_immune($reg);
    $self->_check_land_reachability($reg);
}

sub __calculate_fortification_strength {
    my ($self, $reg) = @_;
    my $units_cnt = 0;
    for ('fortifield', 'encampment') {
        if (defined $reg->extraItems()->{$_}) {
            $units_cnt += $reg->extraItems()->{$_}
        }
    }
    $units_cnt
}

sub extra_defend { 0 }

sub _calculate_land_strength {
    my ($self, $reg) = @_;
    my $ans = 2 + $reg->tokensNum();
    $ans += 'mountain' ~~ $reg->landDescription();
    $ans += $self->__calculate_fortification_strength($reg);
    if ($reg->owner()) {
        $ans += $reg->owner_race()->extra_defend($reg)
    }
    $ans
}

sub __kill_region_owner {
    my ($self, $reg) = @_;
    my $defender = $reg->owner();
    if ($defender) {
        my $tok_cnt = $defender->tokensInHand();
        $reg->owner_race()->clear_reg_and_die($reg);
        $defender = undef if $tok_cnt == $defender->tokensInHand()
    }
    global_game()->add_to_attack_history($reg);
    $defender
}

sub conquer {
    my ($self, $reg, $dice) = @_;

    my $game = global_game();
    my $units_cnt = $self->_calculate_land_strength($reg);
    $units_cnt = 1 if $units_cnt <= 0;

    # FIXME: move db()-> update in Actions/Gameplay.pm
    if (global_user()->tokensInHand() < $units_cnt) {
        if (!is_debug() && !defined $dice) {
            $dice = global_game->random_dice()
        }
        global_game()->lastDiceValue($dice);
        db()->update(global_game());
    }
    $units_cnt -= $dice if defined $dice;
    $units_cnt = 1 if $units_cnt <= 0;
    my ($result, $defender) = (undef, undef);
    if (global_user()->tokensInHand() < $units_cnt) {
        $result = 'badTokensNum';
    } else {
        $result = 'ok';
        $defender = $self->__kill_region_owner($reg);
        global_user()->tokensInHand(global_user()->tokensInHand - $units_cnt);
        $reg->owner(global_user());
        $reg->tokensNum($units_cnt);
        $reg->inDecline(0);
    }

    ($result, $defender, $dice)
}

sub compute_coins {
    my ($self, $reg) = @_;
    scalar @$reg
}

sub clear_reg_and_die {
    my ($self, $reg) = @_;
    my $tok_cnt = $reg->owner()->tokensInHand() + $reg->tokensNum();
    $reg->owner()->tokensInHand($tok_cnt - 1);
}

sub _clear_left_region {
    my ($self, $reg) = @_;
    $reg->owner(undef);
}

sub _clear_region_before_redeploy {
    my ($self, $reg) = @_;
    unless ($reg->inDecline()) {
        $reg->owner(undef);
        $reg->tokensNum(0);
        $reg->inDecline(0);
    }
}

sub _clear_declined_region {
    my ($self, $reg) = @_;
}

sub _redeploy_units {
    my ($self, $moves) = @_;

    for (@{$moves->{units_moves}}) {
        $_->[0]->tokensNum($_->[0]->tokensNum() + $_->[1]);
        $_->[0]->owner(global_user())
    }
}

sub defend {
    my ($self, $moves) = @_;
    assert($moves->{units_sum} <= global_user()->tokensInHand(),
           'notEnoughTokens');

    if (feature('redeploy_all_tokens')) {
        assert($moves->{units_sum} == global_user()->tokensInHand(),
               'thereAreTokensInTheHand');
    }

    $self->_redeploy_units($moves);

    my $attacked_reg = global_game()->lastAttack()->{region};
    my $ok = 0;
    for (global_game()->lastAttack()->{whom}->owned_active_regions()) {
        last if $ok ||= !$self->_regions_are_adjacent($attacked_reg, $_)
    }
    if ($ok) {
        for (@{$moves->{units_moves}}) {
            my $reg = $_->[0];
            assert(!$self->_regions_are_adjacent($attacked_reg, $reg),
                   'badRegion');
        }
    }

    global_user()->tokensInHand(global_user()->tokensInHand - $moves->{units_sum});
}

sub redeploy {
    my ($self, $moves) = @_;

    my @reg = global_user()->owned_active_regions();
    my $tok_cnt = global_user()->tokensInHand() +
                  sum 0, map { $_->tokensNum() } @reg;

    assert($moves->{units_sum} <= $tok_cnt, 'notEnoughTokensForRedeployment');

    global_user()->tokensInHand($tok_cnt - $moves->{units_sum});
    for (@reg) {
        $self->_clear_region_before_redeploy($_);
    }
    $self->_redeploy_units($moves);
    for (@reg) {
        $self->_clear_left_region($_) unless $_->tokensNum()
    }

    if (feature('redeploy_all_tokens') && global_user()->tokensInHand() != 0 &&
        @{$moves->{units_moves}})
    {
        my $reg = $moves->{units_moves}[-1][0];
        $reg->tokensNum($reg->tokensNum() + global_user()->tokensInHand());
        global_user()->tokensInHand(0);
    }

    \@reg
}

sub _decline_region {
    my ($self, $reg) = @_;
    if ($self->inDecline) {
        $self->_clear_declined_region($reg)
    } else {
        $reg->tokensNum(1);
        $reg->inDecline(1);
    }
}

sub decline {
    my ($self) = @_;
    my @usr_reg = global_user()->owned_active_regions();
    $_->owner_race()->_decline_region($_) for @usr_reg;

    my $decline_race = global_user()->declineRace();
    global_game()->put_back_tokens($decline_race) if $decline_race;
    global_user()->declineRace($self);
    $self->inDecline(1);
    global_user()->activeRace(undef);
    global_user()->tokensInHand(0);

    db()->delete($decline_race) if $decline_race;
    db()->update(global_game(), global_user(),
                 global_user()->declineRace(), @usr_reg);
}

sub turnFinished { }

1

__END__

=pod

=head1 Races to implement:

amazons +
dwarves +
elves +
giants +
halflings
humans +
orcs +
ratmen +
skeletons +
sorcerers
tritons +
trolls +
wizards +

=cut
