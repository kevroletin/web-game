use strict;
use warnings;

use Test::More;

use lib '..';
use Tester;
use Tester::OK;
use Tester::Hooks;


init_logs('game_creation');
ok( reset_server(), 'reset server' );

TEST("CreateDefaultMaps");
GO('{ "action": "createDefaultMaps" }',
   '{ "result": "ok" }', {} );


my $user1 = params_same('sid', 'gameId');
my $user2 = params_same('sid', 'gameId');
my $user3 = params_same('sid', 'gameId');

TEST("register 1st user");
GO(
'{
"action": "register",
"username": "user1",
"password": "password1"
}'
,
'{
"result": "ok"
}'
, {} );


TEST("login 1st user");
GO(
'{
"action": "login",
"username": "user1",
"password": "password1"
}'
,
'{
"result": "ok",
"sid": ""
}'
, $user1 );


TEST("Create Game 1st user");
GO(
'{
"action": "createGame",
"sid": "",
"gameName": "game1",
"gameDescr": "game1 descr",
"mapId": 1
}',
'{
"result": "ok",
"gameId": ""
}',
$user1 );


TEST("register 2nd user");
GO(
'{
"action": "register",
"username": "user2",
"password": "password2"
}'
,
'{
"result": "ok"
}'
, {} );


TEST("login 2nd user");
GO(
'{
"action": "login",
"username": "user2",
"password": "password2"
}'
,
'{
"result": "ok",
"sid": ""
}'
, $user2 );


ok( $user1->{_sid} ne $user2->{_sid}, "Sids differ" );


TEST("Create Game 2nd user");
GO(
'{
"action": "createGame",
"sid": "",
"gameName": "game2",
"gameDescr": "game2 descr",
"mapId": 2
}',
'{
"result": "ok",
"gameId": ""
}',
$user2 );


ok( $user1->{_gameId} ne $user2->{_gameId}, "mapIds differ" );


TEST("Create Game with same map without description");
GO(
'{
"action": "createGame",
"sid": "",
"gameName": "game3",
"mapId": 1
}',
'{
"result": "ok",
"gameId": ""
}',
$user1 );


TEST("Create Game without sid");
GO(
'{
"action": "createGame",
"gameName": "game3",
"mapId": 1
}',
'{
"result": "badSid"
}', {} );


TEST("Create Game with same name");
GO(
'{
"action": "createGame",
"sid": "",
"gameName": "game1",
"mapId": 1
}',
'{
"result": "gameNameTaken"
}',
$user1 );

TEST("Create Game without gameName");
GO(
'{
"action": "createGame",
"sid": "",
"mapId": 1
}',
'{
"result": "badJson"
}',
$user1 );


TEST("Create Game without mapId");
GO(
'{
"action": "createGame",
"sid": "",
"gameName": "game1"
}',
'{
"result": "badJson"
}',
$user1 );


TEST("Create Game with wrond mapId");
GO(
'{
"action": "createGame",
"sid": "",
"gameName": "game123",
"mapId": "-20"
}',
'{
"result": "badMapId"
}',
$user1 );

TEST("Join Game");
GO(
'{
"action": "joinGame",
"sid": "",
"gameId": ""
}'
,
'{
"result": "ok"
}',
$user1 );


TEST("Join Game 2nd user");
$user2->{_gameId} = $user1->{_gameId};
GO(
'{
"action": "joinGame",
"sid": "",
"gameId": ""
}'
,
'{
"result": "ok"
}',
$user2 );




TEST("register 3rd user");
GO(
'{
"action": "register",
"username": "user3",
"password": "password3"
}'
,
'{
"result": "ok"
}'
, {} );


TEST("login 3rd user");
GO(
'{
"action": "login",
"username": "user3",
"password": "password3"
}'
,
'{
"result": "ok",
"sid": ""
}'
, $user3 );


TEST("Join to full Game");
$user3->{_gameId} = $user1->{_gameId};
GO(
'{
"action": "joinGame",
"sid": "",
"gameId": ""
}'
,
'{
"result": "tooManyPlayers"
}',
$user3 );


TEST("Join Game twice");
GO(
'{
"action": "joinGame",
"sid": "",
"gameId": ""
}'
,
'{
"result": "alreadyInGame"
}',
$user1 );


TEST("Join Game with bad gameId");
GO(
'{
"action": "joinGame",
"sid": "",
"gameId": "-2000"
}'
,
'{
"result": "badGameId"
}',
$user1 );


TEST("Leave game 2nd");
GO(
'{
"action": "leaveGame",
"sid": ""
}'
,
'{
"result": "ok"
}',
$user2 );


TEST("Leave game twice 2nd");
GO(
'{
"action": "leaveGame",
"sid": ""
}'
,
'{
"result": "notInGame"
}',
$user2 );


TEST("Join Game 3rd");
GO(
'{
"action": "joinGame",
"sid": "",
"gameId": ""
}'
,
'{
"result": "ok"
}',
$user3 );


TEST("SetReadinessStatus 1st");
GO(
'{
"action": "setReadinessStatus",
"sid": "",
"isReady": 1
}'
,
'{
"result": "ok"
}',
$user1 );


TEST("SetReadinessStatus 3rd");
GO(
'{
"action": "setReadinessStatus",
"sid": "",
"isReady": 1
}'
,
'{
"result": "ok"
}',
$user3 );


TEST("SetReadinessStatus 3rd twice");
GO(
'{
"action": "setReadinessStatus",
"sid": "",
"isReady": 1
}'
,
'{
"result": "badGameStage"
}',
$user3 );


TEST("SetReadinessStatus 2nd");
GO(
'{
"action": "setReadinessStatus",
"sid": "",
"isReady": 1
}'
,
'{
"result": "notInGame"
}',
$user2 );


done_testing();
