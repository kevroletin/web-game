package Game::Dispatcher;
use strict;
use warnings;

use Devel::StackTrace::AsHTML;
use Game::Actions::Chat qw(getMessages
                           sendMessage);
use Game::Actions::Debug qw(resetServer
                            doSmth
                            createBadgesPack
                            selectGivenRace
                            getServerFeatures
                            getGameFeatures
                            setGameFeatures);
use Game::Actions::Game qw(aiJoin
                           createGame
                           joinGame
                           leaveGame
                           getGameInfo
                           getGameState
                           getGameList
                           leaveGame
                           loadGame
                           saveGame
                           setReadinessStatus);
use Game::Actions::Gameplay qw(conquer
                               decline
                               defend
                               dragonAttack
                               enchant
                               finishTurn
                               redeploy
                               selectFriend
                               selectRace
                               throwDice);
use Game::Actions::Lobby qw(getUserInfo
                            login
                            logout
                            register);
use Game::Actions::Map qw(createDefaultMaps
                          getMapInfo
                          getMapList
                          uploadMap);
use Game::Environment qw(init_user_by_sid :std :config :response);
use utf8;


sub _is_action_without_sid {
    $_[0] ~~ [qw(aiJoin
                 login
                 register
                 resetServer
                 createDefaultMaps
                 uploadMap
                 getMessages
                 getUserInfo
                 getGameInfo
                 getGameList
                 getGameState
                 getGameInfo
                 getMapList
                 getMapInfo
                 getServerFeatures
                 getGameFeatures
                 saveGame
                 setGameFeatures)]
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
        response_json({result => 'badUserSid'});
        return;
    }

    eval {
        db_lazy_replace();
        $action_handler->($data);
        db()->execute_memorized();
    };
    return unless $@;

    if (ref($@) eq 'Game::Exception::EarlyResponse') {
        response_raw($@->{msg})
    } else {
        response()->content_type('text/html; charset=utf-8');
        my $str = stack_trace()->as_string();#html();
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
