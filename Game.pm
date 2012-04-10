package Game;
use strict;
use warnings;
use v5.10;

use Devel::StackTrace;
use JSON;
use Plack::Response;
use Plack::Request;
use Game::Constants;

use Game::Dispatcher;
use Game::Model;
use Game::Environment qw(:std :config :response);


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

    Game::Environment::init();
    environment($env);

    #config()->{features}{log_requests} = 1;
    #config()->{features}{record_test} = 'auto.t';

    if ($ENV{compatibility} && $ENV{compatibility} eq 'true') {
        $_ = config()->{features};
        $_->{compatibility} = 1;
        $_->{redeploy_all_tokens} = 1;
        $_->{delete_empty_game} = 1;
        $_->{durty_gameState} = 1;
        $_->{durty_gameList} = 1;
    }
    config()->{debug} = $ENV{environment} &&
                        $ENV{environment} eq 'debug';
    response(Plack::Response->new(200));

    response()->headers(['Access-Control-Allow-Origin', '*']);
    response()->content_type('text/x-json; charset=utf-8');

    request(Plack::Request->new($env));
    # TODO: Process errors
    Game::Model::connect_db();
}

sub parse_request {
    my ($env) = @_;

    setup_environment($env);
    my $log = Game::RequestLogger->new();

    my $json = request()->raw_body();
    my $data = '';
    eval {
        $data = from_json($json)
    };

    $log->log_request($json, $data);

    if ($@ || !$data->{action}) {
        response_json({
            result => 'badJson'
        });
    } else {
        use Game::Dispatcher;
        Game::Dispatcher::process_request($data, $env);
    }

    $log->log_response($data);
    $log->record_test($data);

    response()->finalize();
};

1;

package Game::RequestLogger;
use warnings;
use strict;

use JSON;
use Game::Environment qw(:std :response);
use Data::Dumper::Concise;

my $info_actions = [qw(getGameState getGameInfo getGameList getUserInfo
                       getMapInfo getMapList)];

sub new { bless { enabled => 1 }, shift }

sub log_request {
    my ($self, $json, $data) = @_;

    if (!feature('log_requests')) {
        $self->{enabled} = 0
    }

    return unless $self->{enabled};

    print $json, "\n";
}

sub log_response {
    my ($self) = @_;
    return unless $self->{enabled};

    print ref response()->body() eq 'ARRAY' ?
        join "\n", @{response()->body()} :
        response()->body();
    print "\n"
}

sub record_test {
    my ($self, $data) = @_;
    return unless feature('record_test');

    $_ = response()->body();
    my $resp = from_json( ref($_) eq 'ARRAY' ? join '', @$_ : $_ );
    return if $data->{action} ~~ $info_actions || $resp->{result} ne 'ok';

    open my $test, '>>', feature('record_test');
    printf $test "test('%s',\n%s,\n%s);\n\n", $data->{action},
        map { join "\n", map { "    $_" } split "\n", Dumper $_ } $data, $resp;
    close $test;
}

1;

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
