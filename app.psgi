use warnings;
use strict;

use Plack;
use Plack::Builder;
use Client::Runner;
use Game;


builder {
#    enable 'Plack::Middleware::StackTrace';
    enable 'Plack::Middleware::AccessLog';
#    enable 'Plack::Middleware::Lint';

    mount "/" => \&Client::Runner::run;
    mount "/engine" => \&Game::parse_request;
};
