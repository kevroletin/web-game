package Game::Dispatcher;
use strict;
use warnings;

use Include::Enviroment qw(response_json);
use Game::Lobby qw(login logout register);

sub process_request {
    my ($data) = @_;
    eval {
        no  strict 'refs';
        "$data->{action}"->($data);
    };
    if ($@) {
        response_json({result => "badAction"});
    }
}

1

__END__

=head1 NAME

Game::Dispatcher - выбор процедуры для обработки запроса в зависимости от значения поля action запроса
