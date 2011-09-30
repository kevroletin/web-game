package Include::Environment;

use strict;
use warnings;

use JSON;
use Plack::Response;
use Plack::Request;
use Search::GIN::Query::Manual;

use Exporter::Easy (
    OK => [ qw(db
               db_search
               db_scope
               environment
               is_debug
               if_debug
               request
               response
               response_json) ],
);

my ($db,
    $db_scope,
    $environment,
    $is_debug,
    $request,
    $response);

sub db {
    if (@_) { $db = $_[0] }
    $db
}

sub db_search {
    my ($q) = @_;
    my $query = Search::GIN::Query::Manual->new(
       values => $q
    );
    $db->search($query);
}

sub db_scope {
    if (@_) { $db_scope = $_[0] }
    $db_scope
}

sub environment {
    if (@_) { $environment = $_[0] }
    $environment
}

sub is_debug {
    if (@_) { $is_debug = $_[0] }
    $is_debug
}

sub if_debug {
    return unless $is_debug;
    if (@_ > 1 && ref($_[0]) eq 'CODE') {
        my $code = shift;
        $code->(@_)
    } else {
        @_
    }
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
