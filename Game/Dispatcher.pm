=head1 NAME

Game::Dispatcher - вызов обработчика для полученного action

=head1 DESCRIPTION

Единстенная цель модуля - вызвать правильный обработчик для полученного
из запроса action.
Обработчик - процедура, имя которой совпадает с action.
Обработчики определены в других модулях и явно экспортируются из них:

    use Game::Lobby qw(login logout register);

Не используйте экспорт по умолчанию в модулях, содержащих обработчики,
так как это может привести к ошибкам.

=head1 METHODS

=cut

package Game::Dispatcher;
use strict;
use warnings;

use Include::Environment qw(response_json);
use Game::Lobby qw(login logout register);

=head2 process_request

Принимает разобранный JSON, содержащий поле action.
Вызывает обработчик.

=cut

sub process_request {
    my ($data) = @_;

    #TODO: различать не найденный обработчики action-ов и внутренние падения
    # расскоментировать, если хотите скрыть все ошибки от пользователя
#    eval {
        no  strict 'refs';
        "$data->{action}"->($data);
#    };
#    if ($@) {
#        response_json({result => "badAction"});
#    }
}

1

__END__
