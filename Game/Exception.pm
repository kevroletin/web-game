package Game::Exception;
use warnings;
use strict;


sub throw {
    my ($class, $msg, $params) = @_;
    $params = {} unless $params;
    $params->{msg} = $msg;
    bless($params, $class);
    die $params;
}


package Game::Exception::EarlyResponse;
use base 'Game::Exception';

use JSON;

sub throw_json {
    my ($class, $msg, $params) = @_;
    my $j = to_json($msg);
    $class->throw($j, $params)
}

1
