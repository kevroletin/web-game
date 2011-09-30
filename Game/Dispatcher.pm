package Game::Dispatcher;
use strict;
use warnings;

use Scalar::Util qw(reftype);

use Include::Environment qw(response response_json is_debug);
use Game::Lobby qw(login logout register);


sub resetServer {
    `rm tmp/test.db`;
#    `echo -1 > last_game.txt`;
    response_json({result => 'ok'});
}

sub process_request {
    my ($data) = @_;

    my $action_handler = 0;
    {
        no  strict 'refs';
        if (defined &{$data->{action}}) {
            $action_handler = \&{$data->{action}}
        }
    }

    if ($action_handler) {
        if (is_debug()) {
            $action_handler->($data)
        } else {
            eval { $action_handler->($data) };
            if ($@) {
                # TODO: save error in logs
                response->status(500)
            }
        }
    } else {
        response_json({result => "badAction"});
    }
}

1

__END__

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

=head2 process_request

Принимает разобранный JSON, содержащий поле action.
Вызывает обработчик.

=cut

