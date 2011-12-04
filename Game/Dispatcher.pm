package Game::Dispatcher;
use strict;
use warnings;

use Devel::StackTrace::AsHTML;
use Game::Actions::Debug qw(resetServer
                            doSmth
                            setBadge
                            createBadgesPack
                            selectGivenRace);
use Game::Actions::Game qw(createGame
                           joinGame
                           leaveGame
                           getGameState
                           getGameList
                           leaveGame
                           setReadinessStatus);
use Game::Actions::Gameplay qw(conquer decline defend dragonAttack
                               enchant finishTurn redeploy
                               selectFriend selectRace throwDice);
use Game::Actions::Lobby qw(getUserInfo login logout register);
use Game::Actions::Map qw(createDefaultMaps
                          getMapInfo
                          getMapList
                          uploadMap);
use Game::Environment qw(init_user_by_sid is_debug
                         response response_json
                         response_raw stack_trace);
use utf8;


sub _is_action_without_sid {
    $_[0] ~~ [qw(login
                 register
                 resetServer
                 createDefaultMaps
                 uploadMap
                 getUserInfo
                 getGameList
                 getGameState
                 getGameInfo
                 getMapList
                 getMapInfo)]
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

    if (!$action_handler || $data->{action} =~ /^_.*/) {
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
    return unless $@;

    if (ref($@) eq 'Game::Exception::EarlyResponse') {
        response_raw($@->{msg})
    } else {
        response()->content_type('text/html; charset=utf-8');
        my $str = stack_trace()->as_html();
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

