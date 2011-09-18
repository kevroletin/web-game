package Client::Runner;

use strict;
use warnings;

#will be replaced by Mason2
sub run {
    my $env = shift;
    my $status = 200;
    my $headers = ['Content-Type' => 'text/plain'];
    my $body = ["Hello :) I will be client for webgame " .
                "in the future :)"];
    return [ $status, $headers, $body ];
}

1;
