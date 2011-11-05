package Game::Actions::Gameplay;
use warnings;
use strict;

use Game::Actions;
use Game::Environment qw( response_json early_response_json
                          db global_game global_user );
use Moose::Util qw( apply_all_roles );

#TODO: move to separate module or use smth. like Module::Find
use Game::Power::Alchemist;
use Game::Power::Berserk;
use Game::Power::Bivouaking;
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


sub _control_state {
    my ($data) = @_;
    my $a = $data->{action};
    my $game = global_game();
    my $ok = sub {
        unless ($_[0]) {
            early_response_json({result => 'badGameStage'})
        }
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

    if ($a eq 'conquer' ) {
        $curr_usr->();
        $state->('conquer', 'startMoving');
        $ok->(global_user()->activeRace());
    } elsif ($a eq 'decline' ) {
        $curr_usr->();
        $state->('startMoving');
        $ok->(global_user()->activeRace())
    } elsif ($a eq 'defend' ) {
        $state->('defend');
        $ok->($game->lastAttack() &&
              $game->lastAttack()->{whom} eq global_user())
    } elsif ($a eq 'dragonAttack' ) {

    } elsif ($a eq 'enchant' ) {
        $curr_usr->();
        $race->('sorcerers');
        $state->('startMoving', 'conquer')
    } elsif ($a eq 'finishTurn' ) {
        $curr_usr->();
        $state->('redeployed', 'declined')
    } elsif ($a eq 'redeploy' ) {
        $curr_usr->();
        $state->('conquer')
    } elsif ($a eq 'selectFriend' ) {

    } elsif ($a eq 'selectRace' ) {
        $curr_usr->();
        $state->('startMoving');
        $ok->(!global_user()->activeRace())
    } elsif ($a eq 'throwDice' ) {

    }
}

sub conquer {
    my ($data) = @_;
    proto($data, 'regionId');
    _control_state($data);

    my $reg = global_game()->map()->region_by_id($data->{regionId});
    my $race = global_user()->activeRace();
    $race->check_is_move_possible($reg);
    my $defender = $race->conquer($reg);

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

    my $decline_race = global_user()->declineRace();
    global_game()->put_back_tokens($decline_race) if $decline_race;
    global_game()->state('declined');
    global_user()->declineRace(global_user()->activeRace());
    global_user()->declineRace()->inDecline(1);
    global_user()->activeRace(undef);
    global_user()->tokensInHand(0);

    my @usr_reg = global_user()->owned_regions();
    for (@usr_reg) {
        $_->tokensNum(1);
        $_->inDecline(1);
    }

    db()->delete($decline_race) if $decline_race;
    db()->update(global_game(), global_user(),
                 global_user()->declineRace(), @usr_reg);
    response_json({result => 'ok'});
}

sub _moves_from_data {
    my  ($data) = @_;
    unless (defined $data->{regions} &&
            ref($data->{regions}) eq 'ARRAY')
    {
        early_response_json({result => 'badJson'})
    }
    my @moves;
    my $sum = 0;
    my %proc_reg;
    for (@{$data->{regions}}) {
        my $reg = global_game()->map()->region_by_id($_->{regionId});
        unless ($reg->owner() &&
                $reg->owner() eq global_user())
        {
            early_response_json({result => 'badRegion'})
        }
        unless ($_->{tokensNum} =~ /^\d+$/) {
            early_response_json(result => 'badTokensNum')
        }
        if ($proc_reg{$reg}) {
            early_response_json({result => 'badRegion'})
        }
        $proc_reg{$reg} = 1;
        push @moves, [$reg, $_->{tokensNum}];
        $sum += $_->{tokensNum}
    }
    (\@moves, $sum)
}

sub defend {
    my ($data) = @_;
    proto($data, 'regions');
    _control_state($data);

    my $game = global_game();
    my ($moves, $sum) = _moves_from_data($data);
    my @regions = global_user()->activeRace()->redeploy_during_defend($moves, $sum);
    $game->state('conquer');

    db()->update(global_user(), $game, @regions);
    response_json({result => 'ok'})
}

sub dragonAttack {
    my ($data) = @_;
    proto($data, );
}

sub enchant {
    my ($data) = @_;
    proto($data, 'regionId');
    _control_state($data);

    my $reg = global_game()->map()->region_by_id($data->{regionId});
    global_user()->activeRace()->enchant($reg);

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
    if (global_user()->activeRace()) {
        $coins += global_user()->activeRace()->compute_coins(\@reg_a)
    }
    if (global_user()->declineRace()) {
        $coins += global_user()->declineRace()->compute_coins(\@reg_d)
    }
    global_user()->coins(global_user()->coins() + $coins);
    $game->next_player();
    $game->state('startMoving');

    db()->update($game, global_user());
    response_json({result => 'ok', coins => $coins})
}

sub redeploy {
    my ($data) = @_;
    proto($data, 'regions');
    _control_state($data);

    my $game = global_game();
    my ($moves, $sum) = _moves_from_data($data);
    my $regions = global_user()->activeRace()->redeploy($moves, $sum);
    $game->state('redeployed');

    db()->update(global_user(), $game, $game->map(), @$regions);
    response_json({result => 'ok'})
}

sub selectFriend {
    my ($data) = @_;
    proto($data, );
}

sub selectRace {
    my ($data) = @_;
    proto($data, 'position');
    _control_state($data);

    my $game = global_game();

    my $p = $data->{position};
    unless ($p =~ /^\d+$/ && 0 <= $p && $p <= 5) {
        early_response_json({result => 'badPosition'})
    }
    my $coins = $game->bonusMoney()->[$p] - $p;
    if (global_user()->coins() + $coins < 0 ) {
        early_response_json({result => 'badMoneyAmount'})
    }
    global_user()->coins(global_user()->coins + $coins);

    my ($race, $power) = $game->pick_tokens($p);
    my $pair = ("Game::Race::" . ucfirst($race))->new();
    apply_all_roles($pair, ("Game::Power::" . ucfirst($power)));
    global_user()->activeRace($pair);
    global_user()->tokensInHand($pair->tokens_cnt());

    $game->state('conquer');
    db()->store_nonroot($pair);
    db()->update($game, global_user());
    response_json({result => 'ok'});
}

sub throwDice {
    my ($data) = @_;
    proto($data, );
}

1;

