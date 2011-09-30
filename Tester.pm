package Tester;
use warnings;
use strict;

use Data::Compare;
use Data::Dumper;
use JSON;
use LWP;
use LWP::UserAgent;
use Exporter::Easy (
    EXPORT => [ qw(reset_server
                   open_log
                   close_log
                   log_file
                   write_to_log
                   request
                   request_json
                   raw_compare_test
                   hook_sid_to_params
                   hook_sid_from_params
                   hook_sid_from_to_params
                   hook_sid_specified
                   params_same_sid
                   json_compare_test) ],
);

my $url = $ENV{gameurl} ? $ENV{gameurl} :
#                          "http://192.168.1.51/small_worlds";
                          "http://localhost:5000/engine";
my $log_file = undef;

sub reset_server {
    request_json({action => 'resetServer'});
}

sub open_log {
    open $log_file, '>', $_[0];
}

sub close_log {
    close $log_file;
    $log_file = undef;
}

sub get_log_file {
    $log_file
}

sub write_to_log {
    print $log_file @_
}

sub request {
    my ($content) = @_;
    my $ua = LWP::UserAgent->new(agent => "web-game-tester");
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

sub hook_sid_to_params {
    sub {
        $_[1]->{_sid} = $_[0]->{sid} if $_[0]->{sid}
    }
}

sub hook_sid_from_params {
    sub {
        $_[0]->{sid} = $_[1]->{_sid} if $_[1]->{_sid}
    }
}

sub hook_sid_from_to_params {
    sub {
        #from params only if sid eq '' in test
        if (defined $_[1]->{_sid} &&
            defined $_[0]->{sid} && $_[0]->{sid} eq '')
        {
            $_[0]->{sid} = $_[1]->{_sid}
        }
        #to params always
        if (defined $_[0]->{sid}) {
            $_[1]->{_sid} = $_[0]->{sid}
        }
    }
}

sub hook_sid_specified {
    my ($sid) = @_;
    sub {
        $_[0]->{sid} = $sid
    }
}

sub params_same_sid {
    {
        in_hook => hook_sid_from_to_params(),
        res_hook => hook_sid_from_to_params(),
        out_hook => hook_sid_from_to_params()
    }
}

sub json_compare_test {
    _run_json_test(\&_json_compare, @_)
}

1;
