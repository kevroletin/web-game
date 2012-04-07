use warnings;
use strict;

use Plack;
use Plack::App::File;
use Plack::Builder;
use Game;

sub serve_files {
    my ($default_file) = @_;
    sub {
        my ($env) = @_;

        if ($env->{REQUEST_URI} !~ /^\/?$/ ) {
            return Plack::App::File->new(root => './Client')->($env);
        }

        my $status = 200;
        my $headers = ['Content-Type' => 'text/html'];
        open my $h, '<', $default_file;
        return [ $status, $headers, $h ];
    };
}

builder {
#    enable 'Plack::Middleware::StackTrace';
#    enable 'Plack::Middleware::AccessLog';

    mount "/engine" => \&Game::parse_request;
    mount "/" => serve_files('./Client/main.html');
};
