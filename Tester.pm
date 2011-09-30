package Tester;
use warnings;
use strict;

use Data::Compare;
use Data::Dumper;
use JSON;
use LWP;
use LWP::UserAgent;

my $url = $ENV{gameurl} ? $ENV{gameurl} :
                          "http://localhost:5000/engine";

sub request {
    my ($content) = @_;
    my $ua = LWP::UserAgent->new(agent => "web-game-tester");
    my $req = HTTP::Request->new(POST => $url);
    $req->content($content);
    $ua->request($req);
}

sub request_json {
    request(to_json($_[0]));
}

sub _run_test {
    my ($code, $in, $out, %params) = @_;
    my $resp = request($in);
    if ($resp->code() == 200) {
        $code->($in, $out, $resp->content(), %params);
    } else {
        { res => 0,
          quick => 'status != 200; ',
          long => 'server returned: ' .
                  $resp->message() };
    }
}

sub _compare_test {
    my ($in, $out, $res) = @_;
    if ($out eq $res) {
        { res => 0, quick => 'ok' }
    } else {
        { res => 0, quick => 'out != res',
          long => "server returned:\n$res" }
    }
}

sub raw_compare_test {
    _run_test(\&_compare_test, @_)
}

sub _run_json_test {
    my ($code) = shift;

    my $new_code = sub {
        my ($in, $out, $res, %params) = @_;
        my ($out_parsed, $res_parsed);
        eval {
            $out_parsed = from_json($out)
        };
        if ($@) {
            return { res => 0, quick => 'bad json in test',
                     long => $@ }
        }
        eval {
            $res_parsed = from_json($res)
        };
        if ($@) {
            return { res => 0, quick => 'bad json in response',
                     long => "error:\n" . $@ .
                             "\n\nserver returned:\n$res" }
        }
        $code->($in, $out_parsed, $res_parsed, %params)
    };
    _run_test($new_code, @_)
}

sub _json_compare_test {
    my ($in, $out, $res) = @_;
    if (Compare($out, $res)) {
        { res => 0, quick => 'ok' }
    } else {
        { res => 0,
          quick => 'structures differs',
          long => "parsed test:\n" . Dumper($out) .
                  "\nparsed server response:\n" .
                  Dumper($res) }
    }
}

sub json_compare_test {
    _run_json_test(\&_json_compare_test, @_)
}

1;
