package Game::Dispatcher;
use strict;
use warnings;

use utf8;

use Devel::StackTrace::AsHTML;
use Include::Environment qw(init_user_by_sid
                            response response_json
                            response_raw is_debug);
use Game::Lobby qw(login logout register);


# this is action handler
sub resetServer {
    unlink 'tmp/test.db';
    response_json({result => 'ok'});
}

# this is action handler
sub doSmth {
    response_json({result => 'ok'})
}

sub _is_action_without_sid {
    $_[0] eq 'login' ||
    $_[0] eq 'register' ||
    $_[0] eq 'resetServer'
}

sub process_request {
    my ($data, $env) = @_;

    my $action_handler = 0;
    {
        no  strict 'refs';
        if (defined &{$data->{action}}) {
            $action_handler = \&{$data->{action}}
        }
    }

    unless ($action_handler) {
        response_json({result => "badAction"});
        return
    }
    if (!_is_action_without_sid($data->{action}) &&
        !init_user_by_sid($data->{sid}))
    {
        response_json({result => 'badSid'});
        return;
    }

    eval {
        $action_handler->($data)
    };
    if (ref($@) eq 'Devel::StackTrace' ) {
        my $str = $@->as_html();
        utf8::encode($str) if utf8::is_utf8($str);
        response_raw($str);
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

