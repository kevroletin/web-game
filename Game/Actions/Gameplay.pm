use Game::Actions::Gameplay;
use strict;
use warnings;

use Game::Environment qw( global_game global_user );
use Game::Race;
use Game::Power;
use List::Util qw(sum);
use Moose::Util qw( apply_all_roles );
use Data::Dumper::Concise;


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

    if ($a eq 'conquer' ) {
        $curr_usr->();
        $state->('conquer', 'startMoving');
        $ok->(global_user()->activeRace());
    } elsif ($a eq 'decline' ) {
        $curr_usr->();
        $state->('startMoving');
        $ok->($game->activeRace())
    } elsif ($a eq 'defend' ) {
        $state->('defend');
        $ok->($game->lastAttack() &&
              $game->lastAttack()->{whom} eq global_user())
    } elsif ($a eq 'dragonAttack' ) {

    } elsif ($a eq 'enchant' ) {

    } elsif ($a eq 'finishTurn' ) {
        $curr_usr->();
        $state->('redeployed')
    } elsif ($a eq 'redeploy' ) {
        $curr_usr->();
        $state->('conquer')
    } elsif ($a eq 'selectFriend' ) {

    } elsif ($a eq 'selectRace' ) {
        $curr_usr->();
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

    db()->store(grep { defined $_ } global_user(), global_game(),
                            $reg, $defender);
    response_json({result => 'ok'});
}

sub decline {
    my ($data) = @_;
    _control_state($data);

    global_user()->declineRace(global_user()->activeRace);
    global_user()->declinePower(global_user()->activePower);
    global_user()->tokensInHand(0);

    my @usr_reg = global_user()->owned_regions();
    $_->tokensNum(1) for @usr_reg;

    db()->store(global_user(), @usr_reg);
    response_json({result => 'ok'});
}

sub _regions_from_data {
    my  ($data) = @_;
    unless (defined $data->{regions} &&
            ref($data->{regions}) eq 'ARRAY')
    {
        early_response_json({result => 'badJson'})
    }
    my @moves;
    my $sum = 0;
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
        push @moves, [$reg, $_->{tokensNum}];
        $sum += $_->{tokensNum}
    }
    (\@moves, $sum)
}

sub _redeploy_tokens_in_hand {
    my ($data) = @_;

    my ($moves, $sum) = _regions_from_data($data);

    if ($sum > global_user()->tokensInHand()) {
        early_response_json({result => 'notEnoughTokens'})
    }
    global_user()->tokensInHand(global_user()->tokensInHand - $sum);

    for (@$moves) {
        $_->[0]->tokensNum($_->[0]->tokensNum() + $_->[1])
    }

    map { $_->[0] } @$moves
}

sub _redeploy_all_tokens {
    my ($data) = @_;

    my ($moves, $sum) = _regions_from_data($data);

    my @reg = global_user()->owned_regions();
    my $tok_cnt = global_user->tokensInHand() +
                  sum map { $_->tokensNum() } @reg;

    if ($sum > $tok_cnt) {
        early_response_json({result => 'badTokensNum'})
    }

    global_user()->tokensInHand($tok_cnt - $sum);

    for (@reg) {
        $_->tokensNum(0)
    }
    for (@$moves) {
        $_->[0]->tokensNum($_->[1])
    }

    @reg
}

sub defend {
    my ($data) = @_;
    proto($data, 'regions');
    _control_state($data);

    my $game = global_game();

    my @regions = _redeploy_tokens_in_hand($data);
    $game->lastAttack(undef);
    $game->state('conquer');

    db()->store(global_user(), $game, $game->map(), @regions);
    response_json({result => 'ok'})
}

sub dragonAttack {
    my ($data) = @_;
    proto($data, );
}

sub enchant {
    my ($data) = @_;
    proto($data, );
}

sub finishTurn {
    my ($data) = @_;
    proto($data);
    _control_state($data);

    my $game = global_game();

    my $coins = global_user()->owned_regions();
    global_user()->coins(global_user()->coins() + $coins);

    $game->next_player();
    $game->state('startMoving');

    db->store(global_user(), $game);
    response_json({result => 'ok', coins => $coins})
}

sub redeploy {
    my ($data) = @_;
    proto($data, 'regions');#, 'encampments', 'fortifield', 'heroes');
    _control_state($data);

    my $game = global_game();
    my @regions = _redeploy_all_tokens($data);
    $game->state('redeployed');

    db()->store(global_user(), $game, $game->map(), @regions);
    response_json({result => 'ok'})
}

sub selectFriend {
    my ($data) = @_;
    proto($data, );
}

sub selectRace {
    my ($data) = @_;
    proto($data, );
    _control_state($data);

    my $game = global_game();

    # TODO:
    my $race = Game::Race->new();
    apply_all_roles($race, 'Game::Power');
    global_user()->activeRace($race);
    global_user()->tokensInHand(10);

    $game->state('conquer');
    db()->store($game, global_user(), $race);
    response_json({result => 'ok'});
}

sub throwDice {
    my ($data) = @_;
    proto($data, );
}

1;
