package Game::Environment;

use strict;
use warnings;

use Data::Dumper::Concise;
use JSON;
use Plack::Response;
use Plack::Request;
use Search::GIN::Query::Manual;
use Search::GIN::Query::Set;
use Game::Exception;
use Game::Model::Counter;


use Exporter::Easy (
    EXPORT => [qw(assert
                  config
                  feature
                  is_debug
                  global_game
                  global_user)],
    TAGS => [
         std => [qw(assert from_bool bool num config feature
                     is_debug global_game global_user)],
         db => [qw(db db_search db_search_one db_scope inc_counter)],
         config => [qw(environment request stack_trace)],
         response => [qw(response response_json
                         early_response early_response_json
                         response_raw)]
        ],
    OK => [qw(apply_game_features
              assert
              bool
              config
              feature
              from_bool
              db
              db_search
              db_search_one
              db_scope
              early_response
              early_response_json
              environment
              global_game
              global_user
              is_debug
              if_debug
              inc_counter
              init_user_by_sid
              request
              response
              response_json
              response_raw
              stack_trace )]
);


my ($config,
    $db,
    $db_scope,
    $environment,
    $global_user,
    $request,
    $response,
    $stack_trace);

sub init {
    $config = {
               features => {
                            error_description => 1,
                            log_requests => 0,

                            compatibility => 0,
                            redeploy_all_tokens => 0,
                            delete_empty_game => 0,
                            durty_gameState => 0,
                            durty_gameList => 0,
                            join_game_after_creation => 1
                           },
               debug => 0
              };
}

sub apply_game_features {
    my ($game) = @_;
    $_ = config()->{features};
    while (my ($k, $v) = each %{$game->features()}) {
        $_->{$k} = $v
    }
}

sub assert {
    my ($ok, $msg) = (shift, shift);
    return if $ok;
    if (feature('error_description')) {
        early_response_json({result => $msg, @_})
    } else {
        early_response_json({result => $msg})
    }
    1
}

sub bool {
    $_[0] ? JSON::true : JSON::false;
}

sub from_bool {
    $_[0] ? 1 : 0
}

sub num {
    defined $_[0] ? $_[0] : 0
}

sub config {
    return $config unless @_;
}

sub feature {
    return $config->{features} unless @_;
    @{$config->{features}}{@_}
}

sub db {
    if (@_) { $db = $_[0] }
    $db
}

sub db_search {
    return unless @_;
    my @sub_q =
        map { Search::GIN::Query::Manual->new(values => $_) } @_;
    my $q;
    if (@sub_q == 1) {
        $q = $sub_q[0]
    } else {
        $q = Search::GIN::Query::Set->new(
            operation => 'INTERSECT',
            subqueries => [@sub_q]
        );
    }
    $db->search($q)
}

sub db_search_one {
    my @res = db_search(@_)->all();
    if (@res > 1) {
        die "Search returned many items. Query: " . Dumper(@_)
    }
    $res[0]
}

sub db_scope {
    if (@_) { $db_scope = $_[0] }
    $db_scope
}

sub early_response {
    Game::Exception::EarlyResponse->throw(@_)
}

sub early_response_json {
    Game::Exception::EarlyResponse->throw_json(@_)
}

sub environment {
    if (@_) { $environment = $_[0] }
    $environment
}

sub global_game {
    unless ($global_user) {
        early_response_json({result => 'badUserSid'})
    }
    my $g = $global_user->activeGame();
    early_response_json({result => 'notInGame'}) unless $g;
    $g
}

sub global_user {
    if (@_) { $global_user = $_[0] }
    $global_user
}

sub is_debug {
    if (@_) { $config->{debug} = $_[0] }
    $config->{debug}
}

sub if_debug {
    return unless $config->{debug};
    if (@_ > 1 && ref($_[0]) eq 'CODE') {
        my $code = shift;
        $code->(@_)
    } else {
        @_
    }
}

sub inc_counter {
    my ($name) = @_;
    my $cnt = db_search_one({ name => $name },
                            { CLASS => 'Game::Model::Counter' });
    $cnt = Game::Model::Counter->new(name => $name) unless $cnt;
    $cnt->next();
    db()->store($cnt);
    $cnt->value();
}

sub init_user_by_sid {
    my ($sid) = @_;
    return 0 unless defined $sid;
    $global_user = undef;

    my @users = db_search({ sid => $sid })->all();
    if (!@users ) {
        return 0
    } elsif ( @users > 1 ) {
        die "multiple users with same name"
    }

    $global_user = $users[0];

    if (defined $global_user->activeGame()) {
        apply_game_features(global_game());
    }

    1
}

sub request {
    if (@_) { $request = $_[0] }
    $request;
}

sub response {
    if (@_) { $response = $_[0] }
    $response;
}

sub response_json {
    my ($text, $params) = @_;
    $params->{pretty} = 1;
    $response->body(to_json($text, $params))
}

sub response_raw {
    $_[0] = [@_] if ref($_[0]) ne 'ARRAY';
    $response->body($_[0])
}

sub stack_trace {
    if (@_) { $stack_trace = $_[0] }
    $stack_trace
}

1

__END__

=head1 NAME

Include::Environment - глобальные данные

=head1 DESCRIPTION

В ходе обработки запроса существует необходимость обращаться к базе
данных; устанавливать cookies, http headers и т.д, иметь информацию
о текущем пользователе.

Чтобы не передать огромное количество переменных через стек вызова
функций, описанные выше данные храняться в этом модуле и доступны
через реализованные здесь функции.

=head1 METHODS

=head2 db

Устанавливает значение(если предано) и возвращает значение
глобального объекта L<KiokuDB> для доступа к базе данных.

=head2 db_scope

Устанавливает/возарвщает scope object. Он необходим, чтобы
все объекты, полученные из БД не были удалены сборщиком мусора
до тех пор, пока существует scope(необходим при использовании
WeakReferences.
Подробности: L<KiokuDB::Tutorial>.

=head2 environment

Устанавливает/Возвращает hash с информацией об окружении, который
передаёт Plack при запуске приложения.

=head2 request

Устанавливает/Возвращает L<Plack::Request>. Используйте для получения
информации о запросе пользователя.

=head2 response

Устанавливает/Возвращает L<Plack::Response>. Используйте для
манипуляции над ответом, отсылаемым пользователю (изменение
cookies, http headers, тело ответa, статус).

=head2 response_json

Переводит полученные данные в json и устанавливает их в  тело ответа.
Смотрите код для подробностей.

=cut
