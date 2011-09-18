package Game::Lobby;
use strict;
use warnings;

use Include::Enviroment qw(response);

use Exporter::Easy (
    OK => [qw(login logout register)]
);


sub login {
    my ($data) = @_;
    response->body("login");
}

sub logout {
    my ($data) = @_;
    response->body("logout");
}

sub register {
    my ($data) = @_;
    response->body("register");
}


1

__END__

=head1 NAME

Game::Lobby - аутенфикация/регистрация
