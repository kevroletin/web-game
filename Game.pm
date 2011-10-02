package Game;
use strict;
use warnings;

use Devel::StackTrace;
use JSON;
use Plack::Response;
use Plack::Request;

use Game::Environment qw(environment is_debug if_debug
                         request response response_json
                         stack_trace);
use Game::Dispatcher;
use Game::Model;

sub _dier {
    my $t = Devel::StackTrace->new(
                indent => 1, message => $_[0],
                ignore_package => [__PACKAGE__, 'Game::Exception']
            );
    stack_trace($t);
    die @_;
}

$SIG{__WARN__} = \&_dier;
$SIG{__DIE__} = \&_dier;
$SIG{INT} = \&_dier;


sub setup_environment {
    my ($env) = @_;
    environment($env);
    is_debug($ENV{environment} &&
             $ENV{environment} eq 'debug');
    response(Plack::Response->new(200));
    response()->content_type('text/html; charset=utf-8');
    request(Plack::Request->new($env));
    # TODO: Process errors
    Game::Model::connect_db();
}

sub parse_request {
    my ($env) = @_;

    setup_environment($env);

    my $json = request()->raw_body();

    my $data = '';
    eval {
        $data = from_json($json)
    };
    if ($@ or !$data->{action}) {
        response_json({
            result => 'badJson'
        });
    } else {
        Game::Dispatcher::process_request($data, $env);
    }

    response()->finalize();
};

1

__END__

=head1 NAME

Game - запуск приложения

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
