package Tester::New;
use warnings;
use strict;

use Tester::Diff;

use JSON;
use LWP;
use LWP::UserAgent;
use LWP::ConnCache;
use File::Spec;
use Test::More;
use Data::Dumper::Concise;
use Devel::StackTrace;
use Text::Diff;
use Exporter::Easy ( EXPORT => [ qw(actions
                                    done_testing
                                    tests_context
                                    hooks_sync_values
                                    init request
                                    ok
                                    send_test test
                                    true
                                    false
                                    bool
                                    null_or_val_checker
                                    record
                                    replay) ] );

sub true { JSON::true }
sub false { JSON::false }
sub bool { $_[0] ? JSON::true : JSON::false }

use Carp;
$SIG{__DIE__} = \&Carp::confess;
$SIG{__WARN__} = \&Carp::confess;
$SIG{INT} = \&Carp::confess;

my $context;

sub tests_context { $context }

{
    my $actions = Tester::New::ProtocolActions->new();
    sub actions { $actions }
}

sub record {
    init();
    $context->{record_history} = 1;
    $context->{history} = [];
}

sub replay {
    $context->{url} = $_ if ($_ = shift);
    $context->{record_history} = 0;

    my $i = 0;

    for (@{$context->{history}}) {
        test("replay_" . ++$i,
             $_->[0], $_->[1], {}, {stack_level => 2,
                                    print_on_error => $_->[2]});
    }
}

sub message {
    print {$context->{msg_file}} @_;
    for (@_) {
        while (/\n/g) { ++$context->{msg_file_curr_line} }
    }
}
sub write_log { print {$context->{log_file}} @_ }

sub init {
    return if defined $context;
    $context->{url} = $ENV{gameurl} ? $ENV{gameurl} :
                                      "http://localhost:5000/engine";

    my $testname = $0 =~ /^(.*)\..*$/ ? $1 : 'test';
    $context->{log_file_name} = $testname . '.log';
    $context->{msg_file_name} = $testname . '.msg';
    open $context->{log_file}, '>', $context->{log_file_name};
    open $context->{msg_file}, '>', $context->{msg_file_name};
    $context->{msg_file_curr_line} = 0;
    $context->{ua} = LWP::UserAgent->new(agent => "web-game-tester");
    $context->{ua}->conn_cache(LWP::ConnCache->new());
    $context->{server_died_cnt} = 0;
    $context->{record_history} = 0;
    $context->{history} = [];
    $context->{use_text_diff} = 0;
    1
}

sub request {
    my ($content) = @_;
    my $req = HTTP::Request->new(POST => $context->{url});
    $req->content($content);
    my $res = $context->{ua}->request($req);
    write_log( "\n---REQUEST---\n", $a = $req->content() );
    write_log( "\n---RESPONSE---\n", $b = $res->content(), "\n" );
    if ($context->{record_history}) {
        my $t = Devel::StackTrace->new->frame(-1);
        my $place = sprintf( "#   at %s line %s\n", $t->filename(), $t->line());
        push @{$context->{history}}, [$a, $b, $place];
    }
    $res
}

sub _panic_server_crash {
    my ($c, $error) = @_;
    my $cnt = ++$context->{server_died_cnt};
    open my $f, '>', "error_$cnt.htm";
    print $f $error;
    close $f;
    print STDERR "\n ~~~ server died  >(O_o)<  ~~~ \n"
}

sub _safe_request {
    my ($c) = @_;
    my $resp = request($c->{in_json});
    if ($resp->code() != 200) {
        _panic_server_crash($c, $resp->message());
        return { res => 0,  quick => 'http status != 200; ',
                 long => 'server returned: ' . $resp->message() };
    }
    my $resp_msg = eval { from_json($c->{resp_json} = $resp->content()) };
    if (!$@) {
        $c->{resp} = $resp_msg;
        return undef;
    }
    _panic_server_crash($c, $resp->content());
    { res => 0, quick => 'bad json in responce',
      long => 'server returned: ' . $resp->content() }
}

sub send_test {
    my ($in, $out, $params, $test_params) = @_;
    $params ||= {};
    my $c = {};
    ($c->{in}, $c->{out}, $c->{params}) = ($in, $out, $params);

    if (defined $params->{hooks}{before_req}) {
        $params->{hooks}{before_req}->($c);
    }

    $c->{in_json} = ref($in) ? eval { to_json($in, {pretty => 1}) } : $in;
    $c->{out} = ref($out) ? $out : from_json($out);
    if ($@) {
        return ({ res => 0, quick => 'bad json in test INPUT or OUTPUT',
                 long => $@ }, $c)
    };

    my $res = _safe_request($c);
    return ($res, $c) unless defined $c->{resp};

    if (ref($out) eq 'CODE') {
        $res = { res => '1', quick => 'ok', long => 'sub exec' };
        return ($out->($c, $res), $c)
    }

    if (defined $params->{hooks}{after_resp}) {
        $params->{hooks}{after_resp}->($c);
    }

    my $diff = Tester::Diff::compare($c->{resp}, $c->{out},
                                     $test_params->{diff_method});

    my $err = $diff->errors_report();

    unless ($err) {
        return ({ res => 1, quick => 'ok', long => 'ok' }, $c)
    } else {
        my $msg;
        if ($context->{use_text_diff} && defined $c->{resp}) {
            # we can insert subroutines in nested data structures in $c->{out}
            # hence to_json will fail
            $msg = eval { diff map { \to_json($_, {pretty => 1, canonical => 1}) }
                            $c->{out}, $c->{resp} };
        }
        unless ($msg) {
            $msg = sprintf("\n\nexpected:%s\nget:%s\n",
                           map { Dumper($_) } $c->{out}, $c->{resp});
        }
        return ({ res => 0, quick => 'diff failed', long => $err . "\n" . $msg }, $c)
    }
}

sub test {
    my ($test_name, $in, $out, $params, $test_params) = @_;
    init() unless defined $context;
    write_log("---$test_name---");
    my ($res, $c) = send_test($in, $out, $params, $test_params);

    return if $test_params->{show_only_errors} && $res->{ok};

    message(sprintf("%s: %s\n", $test_name, $res->{quick}));
    my $msg_file_line = $context->{msg_file_curr_line};
    if (defined $res->{long} && !$res->{res}) {
        message(sprintf("%s\n\n", $res->{long}))
    } else {
        message("\n")
    }

    my $t = Test::More->builder->new();
    if (defined $test_params->{stack_level}) {
        $t->level($test_params->{stack_level})
    }
    $t->ok($res->{res}, $test_name);
    unless ($res->{res}) {
        my $fh = $t->failure_output();
        if (defined $c->{resp}) {
            print $fh $_ if ($_ = $test_params->{print_on_error});
            printf $fh "#   at %s line %d.\n",
                       $context->{msg_file_name},
                       $msg_file_line
        } else {
            printf $fh "#   %s\n", $res->{long}
        }
    }
}

sub hooks_sync_values {
    my $values = \@_;
    my $from_a_to_b = sub {
        my ($a, $b, $force) = @_;
        for (@$values) {
            if ((exists $b->{$_} || $force) &&
                !defined $b->{$_} && defined $a->{$_})
            {
                $b->{$_} = $a->{$_}
            }
        }
    };
    my $hook_in = sub {
        my ($c) = @_;
        $from_a_to_b->($c->{params}{data}, $c->{in})
    };
    my $hook_out = sub {
        my ($c) = @_;
        $from_a_to_b->($c->{resp}, $c->{params}{data}, 1);
        $from_a_to_b->($c->{params}{data}, $c->{out})
    };
    { hooks => { before_req => $hook_in,
                 after_resp => $hook_out },
      data => {} }
}

sub null_or_val_checker {
    my $val = shift;
    sub {
        $_[1]->{msg} .= ': ' . join ' vs ', map { defined $_  ? $_  : 'undef' } $val, $_[0];
        !defined $_[0] || $_[0] eq $val
    };
}

1;

package Tester::New::ProtocolActions;
use warnings;
use strict;

use Tester::New;

sub new {
    my ($class) = shift;
    my $s = {};
    bless($s, $class);
    $s
}

sub check_tokens_cnt {
    my ($s, $cnt, $params) = @_;
    my $check_state = sub {
        my ($c, $res) = @_;
        my $num = $params->{info}{number_in_game};
        die 'bad test: player number not defined' unless defined $num;
        $_ = eval { $c->{resp}{gameState}{players}[$num]{tokensInHand} };
        my $diff = Tester::Diff::compare($_, $cnt)->errors_report(0);
        $res->{quick} = $diff ?
            "{gameState}{players}[$num]{tokensInHand}" . $diff : 'ok';
        $res->{res} = 0 if $diff;
        $res->{long} = $c->{resp_json};
        $res
    };
    my $res = test( 'check tkns cnt',
                    {action => 'getGameState', sid => undef},
                    $check_state,
                    $params,
                    {show_only_errors => 0,
                     stack_level => 2});
}

sub check_reg {
    my ($s, $reg_num, $item, $params, $stack_level) = @_;
    my $check_state = sub {
        my ($c, $res) = @_;
        $_ = eval {
            $c->{resp}{gameState}{map}{regions}[$reg_num]
        };
        my $diff = Tester::Diff::compare($_, $item, 'AT_LEAST')->errors_report(0);
        $res->{quick} = $diff ?
            "{gameState}{map}{regions}[$reg_num]" . $diff : 'ok';
        $res->{res} = 0 if $diff;
        $res->{long} = $c->{resp_json};
        $res
    };
    my $res = test( 'check region',
                    {action => 'getGameState', sid => undef},
                    $check_state,
                    $params,
                    {show_only_errors => 0,
                     stack_level => $stack_level || 2 });
}

sub check_magic_game_stage {
    my ($self, $stage, $params, $stack_level) = @_;
    my $res = test( 'check game stage',
                    {action => 'getGameState', gameId => undef},
                    {gameState => { stage => $stage } },
                    $params,
                    {show_only_errors => 0,
                     stack_level => $stack_level || 2 });
}

sub _state_vs_num {
    my %h = (
             'wait'    => 1, # ожидаем игроков
             1         => 'wait',
             'begin'   => 0, # игра началась, ждем первых действий
             0         => 'begin',
             'in_game' => 2, # игра во всю идет (первое действие было сделано)
             2         => 'in_game',
             'finish'  => 3, # игра закончилась, но игроки ее еще не покинули
             3         => 'finish',
             'empty'   => 4, # игра закончилась, все игроки покинули ее
             4         => 'empty'
            );
    defined ($_ = $h{$_[0]}) ?
        (defined $_ ? $_ : 'undef') :
        $_[0]
}

sub check_magic_game_state {
    my ($self, $state, $params, $stack_level) = @_;
    my $checker = sub {
        my ($data, $res) = @_;
        unless ( $state ~~ /^\d+$/) {
            $state = _state_vs_num($state);
        }
        $res->{ok} = $state eq $data;
        unless ($res->{ok}) {
            $res->{msg} = sprintf( "%s(%s) vs %s(%s)",
                                   _state_vs_num($data), $data,
                                   _state_vs_num($state), $state );
        }
        $res->{ok}
    };
    my $res = test( 'check game stage',
                    {action => 'getGameState', gameId => undef},
                    {gameState => { state => $checker } },
                    $params,
                    {show_only_errors => 0,
                     stack_level => $stack_level || 2 });
}

sub _last_event_vs_num {
    my %h = (
             'wait'    => 1, # ожидаем игроков
             1         => 'wait',
             'begin'   => 0, # игра началась, ждем первых действий
             0         => 'begin',
             'in_game' => 2, # игра во всю идет (первое действие было сделано)
             2         => 'in_game',
             'finish'  => 3, # игра закончилась, но игроки ее еще не покинули
             3         => 'finish',
             'empty'   => 4, # игра закончилась, все игроки покинули ее
             4         => 'empty',

             'finish_turn' => 4,
             4 => 'finish_turn',
             'select_race' =>  5,
             5 => 'select_race',
             'conquer'  =>  6,
             6 => 'conquer',
             'decline'   =>  7,
             7 => 'decline',
             'redeploy' => 8,
             8 => 'redeploy',
             'throw_dice' => 9,
             9 => 'throw_dice',
             'defend' => 12,
             12 => 'defend',
             'select_friend' => 13,
             13 => 'select_friend',
             'failed_conquer' => 14,
             14 => 'failed_conquer'
            );
    defined ($_ = $h{$_[0]}) ?
        (defined $_ ? $_ : 'undef') :
        $_[0]
}

sub check_magic_last_event {
    my ($self, $la, $params, $stack_level) = @_;
    my $checker = sub {
        my ($data, $res) = @_;
        unless ( $la ~~ /^\d+$/) {
            $la = _last_event_vs_num($la);
        }
        $res->{ok} = $la eq $data;
        unless ($res->{ok}) {
            $res->{msg} = sprintf( "%s(%s) vs %s(%s)",
                                   _last_event_vs_num($data), $data,
                                   _last_event_vs_num($la), $la );
        }
        $res->{ok}
    };
    my $res = test( 'check game stage',
                    {action => 'getGameState', gameId => undef},
                    {gameState => { state => $checker } },
                    $params,
                    {show_only_errors => 0,
                     stack_level => $stack_level || 2 });
}


1;
