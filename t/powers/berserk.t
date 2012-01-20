use strict;
use warnings;

use Test::More;

use JSON;

use lib '..';
use Tester;
use Tester::OK;
use Tester::Hooks;
use Tester::State;
use Tester::CheckState;

init_logs('powers/berserk');
ok( reset_server(123), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'mountain'], ['border', 'farmland'],
  ['border', 'hill'], ['border', 'hill']);


TEST("Select power");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "debug",
"power": "berserk"
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(4, $user1);


TEST("throwDice");
GO(
'{
  "action": "throwDice",
  "sid": ""
}'
,
'{
"result": "ok",
"dice": "2"
}',
$user1 );


TEST("throwDice twice");
GO(
'{
  "action": "throwDice",
  "sid": ""
}'
,
'{
"result": "badStage"
}',
$user1 );


TOKENS_CNT(4, $user1);


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


TOKENS_CNT(3, $user1);


TEST("throwDice");
GO(
'{
  "action": "throwDice",
  "sid": ""
}'
,
'{
"result": "ok",
"dice": "3"
}',
$user1 );


TEST("conquer");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 2
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(2, $user1);


TEST("throwDice");
GO(
'{
  "action": "throwDice",
  "sid": ""
}'
,
'{
"result": "ok",
"dice": "0"
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


TOKENS_CNT(0, $user1);


TEST("throwDice without tokens");
GO(
'{
  "action": "throwDice",
  "sid": ""
}'
,
'{
"result": "badStage"
}',
$user1 );


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 1, "tokensNum": 1},
  {"regionId": 2, "tokensNum": 1},
  {"regionId": 3, "tokensNum": 2}
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


TEST("throwDice without active race");
GO(
'{
  "action": "throwDice",
  "sid": ""
}'
,
'{
"result": "badStage"
}',
$user2 );


done_testing();

