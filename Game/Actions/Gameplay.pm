package Game::Actions::Gameplay;
use warnings;
use strict;

use Game::Actions;
use Game::Environment qw(:std :db :response);
use Moose::Util q(apply_all_roles);

#TODO: move to separate module or use smth. like Module::Find
use Game::Power::Alchemist;
use Game::Power::Berserk;
use Game::Power::Bivouacking;
use Game::Power::Commando;
use Game::Power::Diplomat;
use Game::Power::DragonMaster;
use Game::Power::Flying;
use Game::Power::Forest;
use Game::Power::Fortified;
use Game::Power::Heroic;
use Game::Power::Hill;
use Game::Power::Merchant;
use Game::Power::Mounted;
use Game::Power::Pillaging;
use Game::Power::Seafaring;
use Game::Power::Stout;
use Game::Power::Swamp;
use Game::Power::Underworld;
use Game::Power::Wealthy;

use Game::Race::Amazons;
use Game::Race::Dwarves;
use Game::Race::Elves;
use Game::Race::Giants;
use Game::Race::Halflings;
use Game::Race::Humans;
use Game::Race::Orcs;
use Game::Race::Ratmen;
use Game::Race::Skeletons;
use Game::Race::Sorcerers;
use Game::Race::Tritons;
use Game::Race::Trolls;
use Game::Race::Wizards;

use Exporter::Easy( OK => [qw(conquer
                              decline
                              defend
                              dragonAttack
                              enchant
                              finishTurn
                              redeploy
                              selectFriend
                              selectRace
                              throwDice)] );

sub _control_extra_items {
    my ($regs) = @_;
    my $h = {
        encampments => 'bivouacking',
        fortified_reg => 'fortified',
        heroes_regs => 'heroic'
    };
    for (keys %$h) {
        if (defined $regs->{$_}) {
            assert(global_user()->activeRace()->power_name() eq $h->{$_},
                       'badStage');
            }
    }
}

# FIXME: yes, yes kill me for this code
sub _control_state {
    my ($data) = @_;
    my $a = $data->{action};
    my $game = global_game();
    my $ok = sub {
        assert(shift, 'badStage', stage => $game->state(), @_);
    };
    my $state = sub {
        $ok->($game->state() ~~ [@_])
    };
    my $curr_usr = sub {
        $ok->($game->activePlayer() eq global_user());
    };
    my $race = sub {
        $ok->($game->activePlayer()->activeRace() &&
              $game->activePlayer()->activeRace()->race_name() eq $_[0]);
    };
    my $power = sub {
        $ok->($game->activePlayer()->activeRace() &&
              $game->activePlayer()->activeRace()->power_name() eq $_[0]);
    };
    my $start_moving = sub {
        $state->('conquer');
        $ok->(!@{$game->history()} && !global_game()->raceSelected());
    };
    my $have_race = sub {
        $ok->($game->activePlayer()->activeRace())
    };

    if ($a eq 'conquer' ) {
        $curr_usr->();
        $state->('conquer');
        $ok->(global_user()->activeRace());
        $ok->(!defined global_game()->lastDiceValue(), descr => 'diceUsed');
    } elsif ($a eq 'decline' ) {
        $curr_usr->();
        $have_race->();
        my $race = $game->activePlayer()->activeRace();
        if ($race->power_name() eq 'stout') {
            $state->('conquer', 'redeployed');
        } else {
            $start_moving->();
        }
        $ok->(global_user()->activeRace())
    } elsif ($a eq 'defend' ) {
        $state->('defend');
        $ok->($game->lastAttack() &&
              $game->lastAttack()->{whom} eq global_user())
    } elsif ($a eq 'dragonAttack' ) {
        $curr_usr->();
        $state->('conquer');
        $power->('dragonMaster');
    } elsif ($a eq 'enchant' ) {
        $curr_usr->();
        $race->('sorcerers');
        $state->('conquer')
    } elsif ($a eq 'finishTurn' ) {
        $curr_usr->();
#        $have_race->();
        $state->('redeployed', 'declined')
    } elsif ($a eq 'redeploy' ) {
        $curr_usr->();
        $have_race->();
        $state->('conquer')
    } elsif ($a eq 'selectFriend' ) {
        $curr_usr->();
        $power->('diplomat');
        $state->('redeployed');
    } elsif ($a eq 'selectRace' ) {
        $curr_usr->();
        $start_moving->();
        $ok->(!global_user()->activeRace())
    } elsif ($a eq 'throwDice' ) {
        $curr_usr->();
        $state->('conquer');
        $power->('berserk');
        $ok->(!defined global_game()->lastDiceValue(), descr => 'diceUsed');
    }

    global_game()->last_action( $data->{action} );
}

sub conquer {
    my ($data) = @_;
    proto($data, 'regionId');
    _control_state($data);

    my $reg = global_game()->map()->region_by_id($data->{regionId});
    my $race = global_user()->activeRace();
    $race->check_is_move_possible($reg);
    my $dice = is_debug() ? $data->{dice} : 0;
    my $defender = $race->conquer($reg, $dice);

    if ($defender && $defender->have_owned_regions()) {
        global_game()->state('defend');
    } else {
        global_game()->state('conquer');
    }
    db()->update(grep { defined $_ } global_user(), global_game(),
                            $reg, $defender);
    response_json({result => 'ok'});
}

sub decline {
    my ($data) = @_;
    _control_state($data);

    global_game()->state('declined');
    global_user()->activeRace()->decline();

    response_json({result => 'ok'});
}

sub __moves_pairs_from_array {
    my ($arr, $field, $error_msg) = @_;
    return (undef, undef) unless $arr;
    my %proc_reg;
    my @res;
    my $sum = 0;
    for (@{$arr}) {
        my $reg = global_game()->map()->region_by_id($_->{regionId});
        assert($reg->owner() && $reg->owner() eq global_user(), 'badRegion');
        assert(defined $_->{$field} &&
               $_->{$field} =~ /^\d+$/ && $_->{$field} > 0, $error_msg);
#        assert(!$proc_reg{$reg}, 'badRegion');
#        $proc_reg{$reg} = 1;
        push @res, [$reg, $_->{$field}];
        $sum += $_->{$field}
    }
    (\@res, $sum)
}

sub __fortified_reg_from_data {
    my ($data) = @_;
    return undef unless defined $data->{fortified};
    my $reg_id = $data->{fortified}{regionId};
    unless (defined $reg_id) {
        early_response_json({result => 'badJson'})
    }
    global_game()->map()->region_by_id($reg_id)
}

sub __heroes_regs_from_date {
    my ($data) = @_;
    return undef unless defined $data->{heroes};
    unless (ref($data->{heroes}) eq 'ARRAY') {
        early_response_json({result => 'badJson'})
    }
    my @res;
    for (@{$data->{heroes}}) {
        last if @res > 2;
        push @res, global_game()->map()->region_by_id($_);
    }
    if (@res == 2 && $res[0] eq $res[1] || @res > 2) {
        early_response_json({result => 'badSetHeroCommand'})
    }
    \@res
}

sub _moves_from_data {
    my  ($data) = @_;
    assert(defined $data->{regions} && ref($data->{regions}) eq 'ARRAY',
           'badJson');

    my ($units, $units_sum) =
        __moves_pairs_from_array($data->{regions},
                                'tokensNum',
                                'badTokensNum');
    my ($enc, $enc_sum) =
        __moves_pairs_from_array($data->{encampments},
                                'encampmentsNum',
                                'badEncampmentsNum');
    my $res = {
        encampments => $enc,
        encampments_sum => $enc_sum,
        fortified_reg => __fortified_reg_from_data($data),
        heroes_regs => __heroes_regs_from_date($data),
        units_moves => $units,
        units_sum => $units_sum,
    };
    _control_extra_items($res);
    $res
}

sub defend {
    my ($data) = @_;
    proto($data, 'regions');
    _control_state($data);

    my $moves = _moves_from_data($data);
    global_user()->activeRace()->defend($moves);
    global_game()->state('conquer');

    db()->update(global_user(), global_game(),
                 map { $_->[0] } @{$moves->{units_moves}});
    response_json({result => 'ok'})
}

sub dragonAttack {
    my ($data) = @_;
    proto($data, 'regionId');
    _control_state($data);

    my $reg = global_game()->map()->region_by_id($data->{regionId});

    global_user()->activeRace()->dragonAttack($reg);
    db->update( global_game() );

    response_json({result => 'ok'})
}

sub enchant {
    my ($data) = @_;
    proto($data, 'regionId');
    _control_state($data);

    my $reg = global_game()->map()->region_by_id($data->{regionId});
    global_user()->activeRace()->enchant($reg);
    db->update( global_game() );

    response_json({result => 'ok'})
}

sub finishTurn {
    my ($data) = @_;
    proto($data);
    _control_state($data);

    my $game = global_game();
    my @reg = global_user()->owned_regions();
    my (@reg_a, @reg_d);
    for (@reg) {
        if ($_->inDecline()) {
            push @reg_d, $_
        } else {
            push @reg_a, $_
        }
    }
    my $coins = 0;
    my $stat = {};
    if (global_user()->activeRace()) {
        $coins += global_user()->activeRace()->compute_coins(\@reg_a, $stat)
    }
    if (global_user()->declineRace()) {
        $coins += global_user()->declineRace()->compute_coins(\@reg_d, $stat)
    }
    global_user()->coins(global_user()->coins() + $coins);

    $game->next_player();
    my $tok_cnt = $game->activePlayer()->tokensInHand();
    @reg = $game->activePlayer()->owned_regions();
    for my $reg (@reg) {
        my $d = $reg->tokensNum() - 1;
        if ($d > 0) {
            $reg->tokensNum(1);
            $tok_cnt += $d;
        }
    }
    $game->activePlayer()->tokensInHand($tok_cnt);
    $game->state('conquer');

    db()->update($game, global_user(), $game->activePlayer(), @reg);

    # TODO: may be move most of this action handler into
    # Race.pm->finishTurn
    my $race = global_user()->activeRace();
    my $race_d = global_user()->declineRace();
    $race->turnFinished() if $race;

    my $stat_from_race = sub {
        my ($race) = @_;
        [['Regions', @reg_a + @reg_d],
                     [ucfirst($race->race_name()), $stat->{race} || 0],
                     [ucfirst($race->power_name()), $stat->{power} || 0]]
    };
    $stat = $race   ? $stat_from_race->($race)   :
            $race_d ? $stat_from_race->($race_d) :
            [['Regions', @reg_a + @reg_d]];

    response_json({result => 'ok', statistics => $stat, coins => $coins})
}

sub redeploy {
    my ($data) = @_;
    proto($data, 'regions');
    _control_state($data);

    my $moves = _moves_from_data($data);
    my $reg = global_user()->activeRace()->redeploy($moves);
    global_game()->state('redeployed');

    db()->update(global_user(), global_game(), @$reg);
    response_json({result => 'ok'})
}

sub selectFriend {
    my ($data) = @_;
    _control_state($data);
    proto($data, 'userId');

    my $friend;
    for (@{global_game()->players()}) {
        $friend = $_ if $data->{userId} eq $_->id()
    }
    unless ($friend) {
        early_response_json({result => 'badUserId'})
    }

    global_user()->activeRace()->selectFriend($friend);
    db()->update( global_game() );

    response_json({result => 'ok'})
}

sub selectRace {
    my ($data) = @_;
    proto($data, 'position');
    _control_state($data);

    my $game = global_game();

    my $p = $data->{position};
    assert($p =~ /^\d+$/ && 0 <= $p && $p <= 5, 'badPosition');
    for (0 .. $p - 1) {
        $game->bonusMoney()->[$_] += 1;
    }
    my $coins = $game->bonusMoney()->[$p] - $p;
    if (global_user()->coins() + $coins < 0 ) {
        early_response_json({result => 'badMoneyAmount'})
    }
    global_user()->coins(global_user()->coins + $coins);

    my ($race, $power, $id) = $game->pick_tokens($p);

    my  $pair = ("Game::Race::" . ucfirst($race))->new(tokenBadgeId => $id);
    apply_all_roles($pair, ("Game::Power::" . ucfirst($power)));
    $pair->meta->make_immutable;

    global_user()->activeRace($pair);
    global_user()->tokensInHand($pair->tokens_cnt());
    global_game()->raceSelected(1);

    $game->state('conquer');
    db()->store_nonroot($pair);
    db()->update($game, global_user());

    response_json({tokenBadgeId => $id, result => 'ok'})
}

sub throwDice {
    my ($data) = @_;
    _control_state($data);

    my $dice = is_debug() ? $data->{dice} : 0;
    global_user()->activeRace()->throwDice($dice);
    db->update( global_game() );
}

1;
