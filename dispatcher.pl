use strict;
use warnings;

use Plack::Builder;
use Plack::Response;
use Plack::Request;
use JSON;

use Client::Runner;

use Data::Dumper;


sub parse_request {
    my ($env) = @_;

    my $res = Plack::Response->new(200);
    $res->content_type('text/html');
    my $req = Plack::Request->new($env);

    my $json = $req->raw_body();

    my $data = '';
    eval {
        $data = from_json($json)
    };
    if ($@) {
        my $ans = { result => 'badJson',
                    description => $@ };
        $res->body(to_json($ans, {pretty => 1}));
    } else {
        $res->body(['<pre>', "accepted:\n",
                    Dumper($json), '</pre>']);
    }

    $res->finalize();
};

builder {
    # Include PSGI middleware here

    mount "/" => \&Client::Runner::run;
    mount "/engine" => \&parse_request;
};

