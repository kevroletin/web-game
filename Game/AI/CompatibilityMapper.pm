package Game::AI::CompatibilityMapper;
use warnings;
use strict;

use base 'Game::AI::StdCmd';

sub fix_game_state {
    my ($s, $gs) = @_;
    $s->_fix_players_in_place($gs);
    for my $i (0 .. $#{$gs->{players}}) {
        if ($gs->{players}[$i]{id} eq $gs->{activePlayerId}) {
            $gs->{activePlayerNum} = $i;
        }
    }
    $s->_fix_map_in_place($gs);
    $s->_fix_state_field_in_place($gs);
    $gs->{turn} = $gs->{currentTurn};
}

sub _fix_map_in_place {
    my ($s, $gs) = @_;
    $gs->{mapId} = $gs->{map}{mapId};
    $gs->{mapName} = $gs->{map}{mapName};
    $gs->{maxPlayersNum} = $gs->{map}{playersNum};
    $gs->{playersNum} = int @{$gs->{players}};
    $gs->{turnsNum}= $gs->{map}{turnsNum};

    for (@{$gs->{map}{regions}}) {
        $s->_fix_region_in_place($_)
    }
    $gs->{regions} = $gs->{map}{regions};
};

sub _fix_region_in_place {
    my ($s, $reg) = @_;
    $reg->{landDescription} = $reg->{constRegionState};

    if (defined($reg->{currentRegionState})) {
        $reg->{inDecline} = $reg->{currentRegionState}{inDecline};
        $reg->{owner} = $reg->{currentRegionState}{ownerId};
        $reg->{extraItems} = $reg->{currentRegionState};
        $reg->{tokensNum} = $reg->{currentRegionState}{tokensNum};
    }
};

sub _fix_players_in_place {
    my ($s, $st) = @_;
    for my $player (@{$st->{players}}) {
        $player->{name} = $player->{username};
        $player->{id}   = $player->{userId};
        $player->{readinessStatus} = $player->{isReady};
        if (defined $player->{currentTokenBadge}) {
            $player->{activeRace} =
                lc $player->{currentTokenBadge}{raceName};
            $player->{activePower} =
                lc $player->{currentTokenBadge}{specialPowerName};
        }
        if (defined $player->{declinedTokenBadge}) {
            $player->{declineRace} =
                lc $player->{declinedTokenBadge}{raceName};
            $player->{declinePower} =
                lc $player->{declinedTokenBadge}{specialPowerName};
        }
    }
}

our %state_to_int = (
  wait    => 1,
  begin   => 0,
  in_game => 2,
  finish  => 3,
  empty   => 4
);

our %int_to_state = (
  1 => 'wait',
  0 => 'begin',
  2 => 'in_game',
  3 => 'finish',
  4 => 'empty'
);

sub _fix_state_field_in_place {
    my ($s, $game_state) = @_;

    my $res = $s->get_game_state_fields($game_state->{lastEvent},
                                        $game_state->{state});
    for ('state', 'raceSelected', 'attacksHistory', 'lastDiceValue') {
        $game_state->{$_} = $res->{$_}
    }
    if ($game_state->{defendingInfo}) {
        my $di = $game_state->{defendingInfo};
        $game_state->{state} = 'defend';
        $game_state->{attacksHistory} = [{ who    => $game_state->{activePlayerId},
                                           whom   => $di->{playerId},
                                           region => $di->{regionId} }];
    }
};

our %int_to_last_event = (
  0 => 'notStarted',

  1 => 'wait',
  2 => 'in_game',
  4 => 'finishTurn',
  5 => 'selectRace',
  6 => 'conquer',
  7 => 'decline',
  8 => 'redeploy',
  9 => 'throwDice',
  12=> 'defend',
  13=> ' 3 3selectFriend',
  14=> 'failed_conquer'
);

sub get_game_state_fields {
    my ($s, $last_event_int, $state_int) = @_;

    $last_event_int ||= 1; # wait
    my $last_event = $int_to_last_event{$last_event_int};
    my $state = $int_to_state{$state_int};
    my $result = { attacksHistory => [], raceSelected => 0 };

   $s->info('last_event: ' . $last_event . '(' . $last_event_int . ')');
   $s->info('state: ' . $state . '(' . $state_int . ')');

    if ($state eq 'wait') {
        $result->{state} = 'notStarted';
    #}
    #elsif ($state eq 'begin') {
    #    $result->{state} = 'conquer';
    #    $result->{raceSelected} = 0;
    } elsif ($state eq 'finish' || $state eq 'empty') {
        $result->{state} = 'finished';
    } elsif ($last_event eq 'finishTurn') {
        $result->{state} = 'conquer';
        $result->{raceSelected} = 0;
    } elsif ($last_event eq 'selectRace') {
        $result->{state} = 'conquer';
        $result->{raceSelected} = 1;
    } elsif ($last_event eq 'conquer') {
        $result->{state} = 'conquer';
        $result->{raceSelected} = 1;
        $result->{attacksHistory} = [{}];
    } elsif ($last_event eq 'decline') {
        $result->{state} = 'declined';
    } elsif ($last_event eq 'redeploy') {
        $result->{state} = 'redeployed';
    } elsif ($last_event eq 'throwDice') {
        $result->{state} = 'conquer';
    } elsif ($last_event eq 'defend') {
        $result->{state} = 'conquer';
        $result->{attacksHistory} = [{}];
    } elsif ($last_event eq 'selectFriend') {
        $result->{state} = 'redeployed';
    } elsif ($last_event eq 'failed_conquer') {
        $result->{state} = 'conquer';
        $result->{lastDiceValue} = 'used';
        $result->{attacksHistory} = [{}];
    } else {
        $s->error('can\'t obtain game state field');
        #            $result->{state} = $state;
        $result->{state} = 'conquer';
    }

    $s->info('result: ' , $result);

    return $result;
}

sub fix_game_list {
    my ($s, $games_list) = @_;
    for my $game (@{$games_list}) {
        my $res = $s->get_game_state_fields(undef, $game->{state});
        $game->{state} = $res->{state};
        $game->{gameDescr} = '' if !defined($game->{gameDescr});
        $game->{playersNum} = int @{$game->{players}};
    }
}

sub may_be_fix_game_list {
    my ($s, $games_list) = @_;
    return unless @{$games_list} && $games_list->[0]{state} =~ /^\d+$/;
    $s->fix_game_list($games_list);
}

1
