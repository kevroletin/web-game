package Tester;
use warnings;
use strict;

use Data::Compare;
use Data::Dumper::Concise;
use JSON;
use LWP;
use LWP::UserAgent;
use Exporter::Easy (
    EXPORT => [ qw(init_logs
                   close_logs
                   reset_server
                   open_log
                   close_log
                   open_msg
                   close_msg
                   write_log
                   write_msg
                   request
                   request_json
                   raw_compare_test
                   json_compare_test
                   already_json_test
                   json_custom_compare_test) ],
);

#use LWP::Protocol::http::SocketUnixAlt;
#LWP::Protocol::implementor( http => 'LWP::Protocol::http::SocketUnixAlt' );

use LWP::ConnCache;

my $url = $ENV{gameurl} ? $ENV{gameurl} :
#    'http:tmp/starman.sock//engine';
                          "http://localhost:5000/engine";
my $log_file = undef;
my $msg_file = undef;

sub init_logs {
    my ($test_name) = @_;
    open_log($test_name . '.log');
    open_msg($test_name . '.msg');
}

sub close_logs {
    close_log();
    close_msg();
}

sub reset_server {
    my $r = json_compare_test(
        '{"action": "resetServer"}',
        '{"result": "ok"}'
    );
    $r->{res}
}

sub open_log {
    open $log_file, '>', $_[0];
}

sub close_log {
    close $log_file;
    $log_file = undef;
}

sub open_msg {
    open $msg_file, '>', $_[0];
}

sub close_msg {
    close $msg_file;
    $msg_file = undef;
}

sub write_log {
    print $log_file @_
}

sub write_msg {
    print $msg_file @_
}

my $ua;

sub request {
    my ($content) = @_;
    BEGIN {
        $ua = LWP::UserAgent->new(agent => "web-game-tester");
        $ua->conn_cache(LWP::ConnCache->new())
    }
    my $req = HTTP::Request->new(POST => $url);
    $req->content($content);
    my $res = $ua->request($req);
    if ($log_file) {
        print $log_file "\n***REQUEST***\n" . $req->content();
        print $log_file "\n***RESPONSE***\n" . $res->content();
        print $log_file "\n";
    }
    $res
}

sub request_json {
    request(to_json($_[0]));
}

sub _run_test {
    my ($cmp_code, $in, $out, $params) = @_;
    my $resp = request($in);
    if ($resp->code() == 200) {
        $cmp_code->($in, $out, $resp->content(), $params);
    } else {
        { res => 0,
          quick => 'status != 200; ',
          long => 'server returned: ' .
                  $resp->message() };
    }
}

sub _raw_compare {
    my ($in, $out, $res) = @_;
    if ($out eq $res) {
        { res => 1, quick => 'ok' }
    } else {
        { res => 0, quick => 'out != res',
          long => "server returned:\n$res" }
    }
}

sub raw_compare_test {
    _run_test(\&_raw_compare, @_)
}

# converts to json or creates bad test result
sub _from_json {
    my ($in, $result, $where) = @_;
    my $res;
    eval {
        $res = from_json($in);
    };
    if ($@) {
        $_[1] = { res => 0,
                  quick => 'bad json in ' . ($where | ''),
                  long => "error:\n" . $@ };
        return 0
    }
    $_[1] = $res;
    return 1;
}

my $first_error;

sub _json_cmp_transformer {
    my ($cmp_code, $in, $out, $res, $params) = @_;
    sub {
        my ($in, $out, $res, $params) = @_;
        my ($out_parsed, $res_parsed);
        unless (_from_json($out, $out_parsed, 'test output')) {
            return $out_parsed
        }
        unless (_from_json($res, $res_parsed, 'response')) {
            $res_parsed->{long} = $res_parsed->{long} .
                                  "\n\nserver returned:\n$res";
            unless ($first_error) {
                open my $f, '>', 'first_error.htm';
                print $f $res;
                close $f;
                $first_error = 1;
            }
            return $res_parsed;
        };
        if ($params->{res_hook}) {
            $params->{res_hook}->($res_parsed, $params)
        }
        if ($params->{out_hook}) {
            $params->{out_hook}->($out_parsed, $params)
        }
        $cmp_code->($in, $out_parsed, $res_parsed, $params)
    }
};

sub _run_json_test {
    my ($cmp_code, $in, $out, $params) = @_;
    if ($params->{in_hook}) {
        unless (_from_json($in, $in, 'test input')) {
            return $in
        }
        $params->{in_hook}->($in, $params);
        $in = to_json($in);
    }
    my $new_code = _json_cmp_transformer($cmp_code, @_);
    _run_test($new_code, $in, $out, $params)
}

sub _json_compare {
    my ($in, $out, $res) = @_;
    if (Compare($out, $res)) {
        { res => 1, quick => 'ok' }
    } else {
        { res => 0,
          quick => 'structures differs',
          long => "parsed test:\n" . Dumper($out) .
                  "\nparsed server response:\n" .
                  Dumper($res) }
    }
}

sub json_compare_test {
    _run_json_test(\&_json_compare, @_)
}

sub already_json_test {
    my $in = shift;
    my $compare = sub {
        my ($in, $out, $res) = @_;
        return _json_compare($in, $out, from_json($res))
    };
    _run_test($compare, to_json($in), @_)
}

sub json_custom_compare_test {
    my $compare = shift;
#    _run_json_test(\&_json_compare, @_)
    _run_json_test($compare, @_)
}

1;
