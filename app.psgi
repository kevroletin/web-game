use warnings;
use strict;

use Plack;
use Plack::App::Directory;
use Plack::Builder;
use Client::Runner;
use Game;

builder {
#    enable 'Plack::Middleware::StackTrace';
    enable 'Plack::Middleware::AccessLog';

    mount '/client' =>
        Plack::App::Directory->new({root => "./Client" })->to_app;
    mount "/" => \&Client::Runner::run;
    mount "/engine" => \&Game::parse_request;
};
