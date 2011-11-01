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

init_logs('races/dwarves');
ok( reset_server(), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'mine', 'mountain'], ['border', 'mine'],
  ['border', 'hill'], ['border', 'hill']);


TEST("Select Race");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "dwarves",
"power": "debug"
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(3, $user1);


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


TEST("conquer");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 1
}'
,
'{
"result": "noEnouthUnits"
}',
$user1 );


TEST("redeploy too many tokens");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 0, "tokensNum": 4}
]
}'
,
'{
"result": "badTokensNum"
}',
$user1 );


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 0, "tokensNum": 1}
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
"coins": "2"
}',
$user1 );


TEST("Select Race 2nd user");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "dwarves",
"power": "debug"
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
"result": "ok"
}',
$user2 );


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 3, "tokensNum": 1}
]
}'
,
'{
"result": "ok"
}',
$user2 );


TEST("finish turn");
GO(
'{
"action": "finishTurn",
"sid": ""
}'
,
'{
"result": "ok",
"coins": "1"
}',
$user2 );


TEST("decline 1st");
GO(
'{
"action": "decline",
"sid": ""
}'
,
'{
"result": "ok"
}',
$user1 );


TEST("finish turn");
GO('
{
"action": "finishTurn",
"sid": ""
}'
,
'{
"result": "ok",
"coins": "2"
}',
$user1 );


TOKENS_CNT(0, $user1);


TEST("decline 2nd");
GO(
'{
"action": "decline",
"sid": ""
}'
,
'{
"result": "ok"
}',
$user2 );


TEST("finish turn");
GO('
{
"action": "finishTurn",
"sid": ""
}'
,
'{
"result": "ok",
"coins": "1"
}',
$user2 );


done_testing();
