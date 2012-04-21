package Game::AI::Log;
use warnings;
use strict;

use Data::Dumper::Concise;

sub new {
    my ($class, $params) = @_;
    my $s = ref($class) ? $class : bless {}, $class;
    return $s if $s->{ua};

    $s->{log}{errors}   = *STDERR;
    $s->{log}{warnings} = *STDOUT;
    $s->{log}{std}      = *STDOUT;
    $s->{log}{info}     = *STDOUT;
    $s->{log}{debug}    = *STDOUT;

    #$s->{log}{net}      = *STDOUT;
    open $s->{log}{net}, '>ai.log';

    $s
}

sub _write_to_log {
    my $s = shift;
    my $log_type = shift;
    printf {$s->{log}{$log_type}} "[ %-5s] ", $log_type;
    for (@_) {
        if (ref($_)) {
            print {$s->{log}{$log_type}} Dumper($_)
        } else {
            print {$s->{log}{$log_type}} $_ // '<undef>'
        }
    }
    print {$s->{log}{$log_type}} "\n"
}

sub error { shift->_write_to_log('errors', @_) }

sub warn { shift->_write_to_log('warnings', @_) }

sub info { shift->_write_to_log('info', @_) }

sub log { shift->_write_to_log('std', @_) }

sub debug { shift->_write_to_log('debug', @_) }

sub log_net { shift->_write_to_log('net', @_) }
#sub log_net { }

1;

package Game::AI::Connection;
use warnings;
use strict;
use v5.10;

use LWP;
use LWP::ConnCache;
use JSON;
use Data::Dumper::Concise;

use base 'Game::AI::Log';

sub new {
    my ($class, $params) = @_;
    my $s = ref($class) ? $class : $class->SUPER::new();
    return $s if $s->{ua};

    $s->{ua} = LWP::UserAgent->new(agent => "web-game-ai");
    $s->{ua}->conn_cache(LWP::ConnCache->new());
    $s->{url} = $params->{url} || 'http://localhost:5000/engine';

    $s
}

sub __convert_num_to_num {
    given (ref($_[0])) {
        when ('HASH') {
            for my $key (keys %{$_[0]}) {
                __convert_num_to_num($_[0]->{$key})
            }
        }
        when ('ARRAY') {
            for my $i (0 .. $#{$_[0]}) {
                __convert_num_to_num($_[0]->[$i])
            }
        }
        when ('') {
            $_[0] += 0 if $_[0] =~ /^\d+$/
        }
    }
    $_[0]
}

sub send_cmd {
    my ($s) = shift;
    my $act;
    my $cmd = @_ > 1 ? {@_} : $_[0];
    if (ref($cmd) eq 'HASH') {
        $act = $cmd->{action};
        $cmd->{sid} = $s->{data}{sid} if defined $s->{data}{sid};
        __convert_num_to_num($cmd);
        $cmd = to_json($cmd);
        $s->log_net($cmd);
    } elsif (ref($cmd)) {
        die 'should be HASH or string with json'
    }

    my $req = HTTP::Request->new(POST => $s->{url});
    $req->content($cmd);
    my $res = $s->{ua}->request($req);
    $_ = eval{ from_json($res->content()) };
    if ($@) {
        die $@ . Dumper($res->content())
    }
    $s->{resp_cache}{$act} = $_ if $act;
    $s->log_net($_);
    $_;
}

1;

package Game::AI::StdCmd;
use warnings;
use strict;

use base 'Game::AI::Connection';

sub cmd_get_games_list {
    my ($s) = @_;
    $_ = $s->send_cmd(action => 'getGameList');
    $_->{games}
}

sub cmd_get_game_state {
    my ($s) = @_;
    $_ = $s->send_cmd(action => 'getGameState',
                      gameId => $s->{data}{gameId});
    $_->{gameState}
}

sub cmd_conquer {
    my ($s, $reg_id) = @_;
    $s->send_cmd(action   => 'conquer',
                 regionId => $reg_id);
}

sub cmd_select_race {
    my ($s, $pos) = @_;
    $s->send_cmd(action   => 'selectRace',
                 position => $pos);
}

1;

package Game::AI::CompatibilityLayer;
use warnings;
use strict;
use v5.10;

use base 'Game::AI::CompatibilityMapper';
#use base 'Game::AI::StdCmd';

sub cmd_get_games_list {
    my $s = shift;
    my $list = $s->SUPER::cmd_get_games_list(@_);
    $s->may_be_fix_game_list($list);

    $list
}

sub cmd_get_game_state {
    my $s = shift;
    my $state = $s->SUPER::cmd_get_game_state();
    unless (defined $state->{activePlayerNum}) {
        $s->fix_game_state($state);
    }
    $state
}

sub translate_state { shift }

sub last_map_regions {
    shift->{resp_cache}{getGameState}{gameState}{regions};
}

sub last_game_state {
    my $s = shift;
    $s->cmd_get_game_state() unless defined $s->{resp_cache}{getGameState};
    $s->{resp_cache}{getGameState}{gameState}
}

sub cmd_get_map_info {
    ...;
    my ($s, $map_id) = @_;
    $map_id //= $s->last_game_state()->{mapId};
    $s->send_cmd(action => 'getMapInfo', mapId => $map_id);
}

sub check_you_turn_by_state {
    my ($s, $state) = @_;

    given ($state->{state}) {
        when ('notStarted') {
            return 0
        }
        when ('finished') {
            return 1
        }
        when ('defend') {
            return 1 if $state->{attacksHistory}[-1]{whom} eq $s->{data}{id}
        }
        default {
            return 1 if $s->active_player($state)->{id} eq $s->{data}{id};
        }
    }
    undef
}

sub active_player {
    my ($s, $state) = @_;
    $state ||= $s->last_game_state();
    $state->{players}[ $state->{activePlayerNum} ]
}

sub defender {
    my ($s, $state) = @_;
    $state ||= $s->last_game_state();
    for (@{$state->{players}}) {
        if ($_->{userId} eq  $state->{attacksHistory}[-1]{whom}) {
            return $_
        }
    }
    undef
}

sub determine_action_by_state {
    my ($s, $state) = @_;

    given ($state->{state}) {
        when ('conquer') {
            return 'redeploy' if (defined $s->{lastDiceValue});
            if (!$s->active_player()->{activeRace}) {
                return 'select_race'
            } elsif (!@{$state->{attacksHistory}}) {
                return 'decline_or_conquer'
            } else {
                return 'conquer'
            }
        }
        when ('defend') {
            return 'defend'
        }
        when ('redeploy') {
            return 'redeploy'
        }
        when ('redeployed') {
            return 'finish_turn'
        }
        when ('declined') {
            return 'finish_turn'
        }
        when ('finished') {
            return 'leave_game'
        }
    }
}

1;

package Game::AI::FindGame;
use warnings;
use strict;

use base 'Game::AI::CompatibilityLayer';

sub new {
    my $class = shift;
    my $s = ref($class) ? $class : $class->SUPER::new(@_);
    $s
}

sub _explore_list {
    my ($s, $list) = @_;
    for (@{$list}) {
        if ($_->{aiRequiredNum}) {
            return $_->{gameId}
        }
    }
    undef
}

sub find_game {
    my ($s, $params) = @_;
    $s->info('looking for open games');

    my $find_game_cv = AnyEvent->condvar;
    my $wait_game;
    $wait_game = AnyEvent->timer(
        after => $params->{after} // 0,
        interval => $params->{interval} // 2,
        cb => sub {
            my $game_id = $s->_explore_list($s->cmd_get_games_list());
            if (defined $game_id) {
                $s->info(sprintf 'found open game gameId = %s', $game_id);
                undef $wait_game;
                $find_game_cv->send($game_id);
            }
        },
    );
    $find_game_cv->recv;
}

sub _send_ready {
    my ($s) = @_;
#    my $ok = 0;
#    while (!$ok) {
        $_ = $s->send_cmd( action => "setReadinessStatus",
                           isReady => 1,
                           sid => $s->{data}{sid} );
#        $ok = $_->{result} eq 'ok'
#    }
}

sub join_game {
    my ($s, $game_id) = @_;
    my $r = $s->send_cmd(action => 'aiJoin',
                         gameId => $game_id + 0);

    return undef if $r->{result} ne 'ok';
    $s->{data}{gameId} = $game_id;
    $s->{data}{sid}    = $r->{sid};
    $s->{data}{id}     = $r->{id};
    $s->info(sprintf "gameId: %s; sid: %s; id: %s",
                     @{$s->{data}}{'gameId', 'sid', 'id'});
    # should we do this ?
    $s->_send_ready();
    $s->join_game_hook();
    1
}

sub continue_game {
    my ($s, $game_id) = @_;
    $s->{data}{gameId} = $game_id;
    $s->join_game_hook();
}

sub find_and_join_game {
    my ($s) = @_;
    my $ok = 0;
    while (!$ok) {
        my $game_id = $s->find_game();
        $ok = $s->join_game($game_id);
    }
}

sub bruteforce_join_game {
    my ($s, $params) = @_;
    $s->info('trying to find open game using bruteforce...' .
             'thanks for Terentryv/Nazarov team');
    my $find_game_cv = AnyEvent->condvar;
    my $wait_game;
    $wait_game = AnyEvent->timer(
        after => $params->{after} // 0,
        interval => $params->{interval} // 2,
        cb => sub {
            my $games = $s->cmd_get_games_list();
            $s->info(sprintf 'exists %s games', int @$games);
            for my $game (@$games) {
                if ($s->join_game($game->{gameId})) {
                    $s->info(sprintf 'found open game gameId = %s', $game->{gameId});
                    undef $wait_game;
                    $find_game_cv->send($game->{gameId});
                    return
                }
            }
        },
    );
    $find_game_cv->recv;
}

sub wait_your_turn {
    my ($s, $params) = @_;
    $s->info('wait your turn');

    my $your_turn_cv = AnyEvent->condvar;
    my $wait_game;
    $wait_game = AnyEvent->timer(
        after => $params->{after} // 0,
        interval => $params->{interval} // 1,
        cb => sub {
            my $game_state = $s->cmd_get_game_state();
            if ($s->check_you_turn_by_state($game_state)) {
                undef $wait_game;
                $your_turn_cv->send();
            }
        },
    );
    $your_turn_cv->recv;
}

1;

package Game::AI::Base;
use warnings;
use strict;

use AnyEvent;

use base 'Game::AI::FindGame';

sub play {
    my ($s, $params) = @_;
    $s->info('play');
    while (defined $s->{data}{gameId}) {
        $s->wait_your_turn();
        $s->dispatch_action();
    }
}

sub dispatch_action {
    my ($s, $state) = @_;
    $state ||= $s->last_game_state();

    my $act = $s->determine_action_by_state($state);
    $s->execute_action($act)
}

sub execute_action {
    my ($s, $act) = @_;

    my $state = $s->last_game_state();
    if (!defined $s->{data}{prev_turn} ||
        $s->{data}{prev_turn} ne $state->{turn})
    {
        $s->{data}{prev_turn} = $state->{turn};
        $s->before_turn_hook();
    }

    $s->info('execute action: ' . $act);
    $s->before_act_hook($act);
    $_ = 'act_' . $act;
    my $res = $s->$_();
    $s->after_act_hook($act);

    if ($act ~~ ['finish_turn']) {
        $s->after_turn_hook();
    }

    $res
}

sub join_game_hook { }

sub leave_game_hook { }

sub before_turn_hook { }

sub after_turn_hook { }

sub before_act_hook { }

sub after_act_hook { }

sub act_select_race { ... }

sub act_decline_or_conquer { ... }

sub act_conquer { ... }

sub act_defend { ... }

sub act_redeploy { ... }

sub act_redeployed { ... }

sub act_finish_turn { ... }

sub act_leave_game {
    my ($s) = @_;
    $s->leave_game_hook();
    $_ = $s->send_cmd(action => 'leaveGame');
    if ($_->{result} ~~ ['ok', 'notInGame']) {
        delete $s->{data}{gameId};
    }
}

1;
