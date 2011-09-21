=head1 NAME

Include::Enviroment - глобальные данные

=head1 DESCRIPTION

В ходе обработки запроса существует необходимость обращаться к базе
данных; устанавливать cookies, http headers и т.д, иметь информацию
о текущем пользователе.

Чтобы не передать огромное количество переменных через стек вызова
функций, описанные выше данные храняться в этом модуле и доступны
через реализованные здесь функции.

=head1 METHODS

=cut

package Include::Enviroment;

use strict;
use warnings;

use JSON;
use Plack::Response;
use Plack::Request;

use Exporter::Easy (
    OK => [ qw(db
               db_scope
               enviroment
               request
               response
               response_json) ],
);

my ($db,
    $db_scope,
    $enviroment,
    $request,
    $response);

=head2 db

Устанавливает значение(если предано) и возвращает значение
глобального объекта L<KiokuDB> для доступа к базе данных.

=cut

sub db {
    if (@_) { $db = $_[0] }
    $db
}

=head2 db_scope

Устанавливает/возарвщает scope object. Он необходим, чтобы
все объекты, полученные из БД не были удалены сборщиком мусора
до тех пор, пока существует scope(необходим при использовании
WeakReferences.
Подробности: L<KiokuDB::Tutorial>.

=cut

sub db_scope {
    if (@_) { $db_scope = $_[0] }
    $db_scope
}

=head2 enviroment

Устанавливает/Возвращает hash с информацией об окружении, который
передаёт Plack при запуске приложения.

=cut

sub enviroment {
    if (@_) { $enviroment = $_[0] }
    $enviroment
}

=head2 request

Устанавливает/Возвращает L<Plack::Request>. Используйте для получения
информации о запросе пользователя.

=cut

sub request {
    if (@_) { $request = $_[0] }
    $request;
}

=head2 response

Устанавливает/Возвращает L<Plack::Response>. Используйте для
манипуляции над ответом, отсылаемым пользователю (изменение
cookies, http headers, тело ответa, статус).

=cut response

sub response {
    if (@_) { $response = $_[0] }
    $response;
}

=head2 response_json

Переводит полученные данные в json и устанавливает их в  тело ответа.
Смотрите код для подробностей.

=cut

sub response_json {
    my ($text, $params) = @_;
    $params->{pretty} = 1;
    $response->body(to_json($text, $params))
}

1

__END__

