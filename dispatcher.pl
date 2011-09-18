use strict;
use warnings;

use Plack::Builder;

use Client::Runner;

my $app = sub {
    my $env = shift;
    my $status = 200;
    my $headers = ['Content-Type' => 'text/plain'];
    my $body = ["Hello :) I will be webgame in the future :)"];
    return [ $status, $headers, $body ];
};

builder {
    # Include PSGI middleware here
    enable "Session::Cookie";

    mount "/" => \&Client::Runner::run;
    mount "/engine" => $app;
};

