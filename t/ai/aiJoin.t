use strict;
use warnings;

use Test::More;

use lib '..';
use Tester;
use Tester::OK;
use Tester::Hooks;
use JSON;

sub CHECK_AI_REQUIRED_NUM {
    my ($num, $params) = @_;
    # TODO: remove such code from tests. Use Diff approach of Nazarov/Terentyev team
    my $cmp = sub {
        my ($in, $out, $res) = @_;
        my $data = $res->{games}[0]{aiRequiredNum};
        unless (defined $data) {
            return { res => 0, quick => 'bad aiRequiredNum',
                     long => 'aiRequiredNum not defined'}
        }
        unless ($data eq $num) {
            return { res => 0, quick => 'ok',
                     long => "bad aiRequiredNum: $data != $num"}
        }
        { res => 1, quick => 'ok' }
    };
    my $in = '{"action": "getGameList", "sid": ""}';
    OK( json_custom_compare_test($cmp, $in, '{}', $params),
        'check aiRequiredNum field in gameList' );
}


init_logs('ai/game_creation');
ok( reset_server(), 'reset server' );

TEST("upload map");
GO('{
   "turnsNum" : "10",
   "regions" : [
      {
         "population" : 0,
         "bonusCoords" : [
            10,
            60
         ],
         "landDescription" : [
            "border",
            "farmland"
         ],
         "adjacent" : [
            2,
            3
         ],
         "coordinates" : [
            [
               0,
               0
            ],
            [
               0,
               100
            ],
            [
               100,
               100
            ],
            [
               100,
               0
            ]
         ],
         "raceCoords" : [
            10,
            10
         ],
         "powerCoords" : [
            60,
            10
         ]
      },
      {
         "population" : 0,
         "landDescription" : [
            "border",
            "farmland"
         ],
         "adjacent" : [
            1,
            4
         ],
         "coordinates" : [
            [
               0,
               100
            ],
            [
               0,
               200
            ],
            [
               100,
               200
            ],
            [
               100,
               100
            ]
         ],
         "raceCoords" : [
            10,
            110
         ]
      },
      {
         "population" : 0,
         "landDescription" : [
            "border",
            "hill"
         ],
         "adjacent" : [
            1,
            4
         ],
         "coordinates" : [
            [
               100,
               0
            ],
            [
               100,
               100
            ],
            [
               200,
               100
            ],
            [
               200,
               0
            ]
         ],
         "raceCoords" : [
            110,
            10
         ]
      },
      {
         "population" : 0,
         "landDescription" : [
            "border",
            "hill"
         ],
         "adjacent" : [
            2,
            3
         ],
         "coordinates" : [
            [
               100,
               100
            ],
            [
               100,
               200
            ],
            [
               200,
               200
            ],
            [
               200,
               100
            ]
         ],
         "raceCoords" : [
            110,
            110
         ]
      }
   ],
   "action" : "uploadMap",
   "mapName" : "uploadedMap",
   "playersNum" : 2
}',
'{
   "mapId" : 1,
   "result" : "ok"
}', {}
);


my $user1 = params_same('sid', 'userId', 'gameId');
my $user2 = params_same('sid', 'userId', 'gameId');
my $ai1 = params_same('sid', 'gameId');
my $ai2 = params_same('sid', 'gameId');

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
, $user1 );


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
"sid": "",
"userId": ""
}'
, $user1 );


TEST("Create Game with ai");
GO(
'{
"action": "createGame",
"ai": "1",
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

CHECK_AI_REQUIRED_NUM(1, $user1);

=begin comment

getGameInfo isn't standart action => should not be tested

# TODO: remove such code from tests. Use Diff approach of Nazarov/Terentyev team
my $ai_cnt = 1;
my $cmp = sub {
    my ($in, $out, $res) = @_;
    unless (defined $res->{gameInfo}{ai}) {
        return { res => 0, quick => 'bad ai',
                 long => 'ai not defined'}
    }
    unless ($res->{gameInfo}{ai} eq $ai_cnt) {
        return { res => 0, quick => 'ok',
                 long => "bad ai cnt: $res->{ai} != $ai_cnt"}
    }
    { res => 1, quick => 'ok' }
};
my $in = '{"action": "getGameInfo", "sid": ""}';
OK( json_custom_compare_test($cmp, $in, '{}', $user1), 'check ai field in gameState' );

=end comment


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
"sid": "",
"userId": ""
}'
, $user2 );


TEST("Join 1st ai");
GO(
'{
"action": "aiJoin",
"gameId": 1
}'
,
'{
"result": "ok",
"sid": ""
}'
, $ai1 );


CHECK_AI_REQUIRED_NUM(0, $user1);


TEST("Join 2nd ai to full game");
GO(
'{
"action": "aiJoin",
"gameId": 1
}'
,
'{
"result": "tooManyAi"
}'
, $ai1 );


CHECK_AI_REQUIRED_NUM(0, $user1);


TEST("Join 2nd user to full Game");
$user2->{_gameId} = $user1->{_gameId};
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
$user2 );


done_testing();
