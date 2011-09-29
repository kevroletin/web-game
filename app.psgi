use strict;
use warnings;

use JSON;
use Plack::Builder;
use Plack::Response;
use Plack::Request;

use Client::Runner;
use Include::Environment qw(environment is_debug if_debug
                            request response response_json);
use Game::Dispatcher;
use Model::Configurator;

use Data::Dumper;


sub setup_environment {
    my ($env) = @_;
    environment($env);
    is_debug($ENV{environment} &&
             $ENV{environment} eq 'debug');
    response(Plack::Response->new(200));
    response()->content_type('text/javascript');
    request(Plack::Request->new($env));
    # TODO: Process errors
    Model::Configurator::connect_db();
}

sub parse_request {
    my ($env) = @_;

#    return [200, [], [Dumper \%ENV]];
    #set global response, request and env objects
    setup_environment($env);

    my $json = request()->raw_body();

    my $data = '';
    eval {
        $data = from_json($json)
    };
    if ($@ or !$data->{action}) {
        response_json({
            result => 'badJson',

    if_debug(description => $@ ? $@ : 'no action field')

});
    } else {
        Game::Dispatcher::process_request($data);
    }

    response()->finalize();
};

builder {
    # Include PSGI middleware here

    mount "/" => \&Client::Runner::run;
    mount "/engine" => \&parse_request;
};

__END__

=head1 NAME

app.psgi - запуск приложения

=head1 DESCRIPTION

Запуск приложения состоит из нескольких шагов:

=over

=item * разбор полученного в запросе json,

=item * загрузка конфигурации

=item * соединение с базой данных

=item * инициализация веб-сессии(поиск sid-а в базе данных)

=back

=head1 METHODS

=head2 setup_environment

Инициализирует глобальные переменные из L<Include::Environment>

=head2 parse_request

Разбирает JSON, полученный в http-запросе и отправляет полученные
данные на дальнейшую обработку в L<Game::Dispatcher>

=head2 builder

Создаёт приложение Plack. Для подробностей смотрите L<Plack> и
L<Plack::Builder>

=cut
