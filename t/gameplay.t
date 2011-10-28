use strict;
use warnings;

use Test::More;

use JSON;

use lib '..';
use Tester;
use Tester::OK;
use Tester::Hooks;


init_logs('gameplay');
ok( reset_server(), 'reset server' );

my $user1 = params_same('sid', 'gameId', 'mapId', 'coins');
my $user2 = params_same('sid', 'gameId', 'coins');

#+---------------+----------------+
#|0              |1               |
#| border        |  border        |
#| coast         |  forest        |
#| mountain      |     /|\        |
#|   .           |     /|\        |
#|   |\_         |    /_|_\       |
#| .-   \-.      |      |         |
#+---------------+------|---------+
#|2              |3               |
#| border        | border         |
#| sea           | coast          |
#|               | hill           |
#|               |________________|
#| ~  ~  ~  ~    |''''''''''''''''|
#|  ~   ~  ~     |''''''''''''''''|
#| ~  ~  ~  ~    |''''''''''''''''|
#+---------------+----------------+

TEST("upload map");
GO(to_json({
  action => "uploadMap",
  mapName => "uploadedMap",
  turnsNum => "10",
  playersNum => 2,
  regions => [
    {
      adjacent => [ 1, 2 ],
      landDescription => [
        "mountain",
        "coast",
        "border"
      ],
      population => 0
    },
    {
      adjacent => [ 0, 3 ],
      landDescription => [
        "forest",
        "border"
      ],
      population => 0
    },
    {
      adjacent => [ 0, 3 ],
      landDescription => [
        "sea",
        "coast",
        "border"
      ],
      population => 0
    },
    {
      adjacent => [ 1, 2 ],
      landDescription => [
        "hill",
        "coast",
        "border"
      ],
      population => 0
    }
  ]
}),
'{
"result": "ok",
"mapId": ""
}',
$user1 );

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
"mapId": ""
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


TEST("createBadgesPack");
GO(
'{
"action": "createBadgesPack",
"sid": "",
"races": ["amazons", "humans"],
"powers": ["alchemist", "berserk"]
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


TEST("1st user ready");
GO(
'
{
  "action": "setReadinessStatus",
  "sid": "",
  "isReady": 1
}'
,
'{
"result": "ok"
}',
$user1 );


TEST("2nd user ready");
GO(
'
{
  "action": "setReadinessStatus",
  "sid": "",
  "isReady": 1
}'
,
'{
"result": "ok"
}',
$user2 );


TEST("Select Race");
GO(
'{
"action": "selectRace",
"sid": "",
"position": 0
}'
,
'{
"result": "ok"
}',
$user1 );


TEST("conquer");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 0
}'
,
'{
"result": "ok"
}',
$user1 );


TEST("conquer not ajasent");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 3
}'
,
'{
"result": "badRegion"
}',
$user1 );


TEST("conquer");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 1
}'
,
'{
"result": "ok"
}',
$user1 );


TEST("conquer sea");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 2
}'
,
'{
"result": "badRegion"
}',
$user1 );


TEST("conquer");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 3
}'
,
'{
"result": "ok"
}',
$user1 );


TEST("redeploy on sea");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 0, "tokensNum": 1},
  {"regionId": 1, "tokensNum": 2},
  {"regionId": 2, "tokensNum": 3}
]
}'
,
'{
"result": "badRegion"
}',
$user1 );


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 0, "tokensNum": 1},
  {"regionId": 1, "tokensNum": 2},
  {"regionId": 3, "tokensNum": 3}
]
}'
,
'{
"result": "ok"
}',
$user1 );


TEST("finish turn");
GO(
'{
"action": "finishTurn",
"sid": ""
}'
,
'{
"result": "ok",
"coins": "3"
}',
$user1 );


TEST("conquer");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 3
}'
,
'{
"result":"badGameStage"
}',
$user2 );


TEST("Select Race");
GO(
'{
"action": "selectRace",
"sid": "",
"position": 0
}'
,
'{
"result": "ok"
}',
$user2 );


TEST("conquer");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 3
}'
,
'{
"result":"ok"
}',
$user2 );


TEST("conquer");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 1
}'
,
'{
"result":"badGameStage"
}',
$user2 );


TEST("defend wrong user");
GO(
'{
  "action": "defend",
  "sid": "",
  "regions": [{"regionId": 0, "tokensNum": 3}]
}'
,
'{
"result":"badGameStage"
}',
$user2 );


TEST("defend");
GO(
'{
  "action": "defend",
  "sid": "",
  "regions": [{"regionId": 0, "tokensNum": 3}]
}'
,
'{
"result":"ok"
}',
$user1 );



done_testing();

=begin comment

TEST("Select Race");
GO(
'{
"action": "selectRace",
"race": "trolls",
"power": "commando",
"sid": ""
}'
,
'{
"result": "ok"
}',
$user1 );

=cut comment
