use strict;
use warnings;

use Test::More;

use JSON;

use lib '..';
use Tester;
use Tester::OK;
use Tester::Hooks;
use Tester::State;

init_logs('races/humans');
ok( reset_server(), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'farmland'], ['border', 'farmland'],
  ['border', 'hill'], ['border', 'hill']);


TEST("Select Race");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "humans",
"power": "debug"
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


TEST("redeploy too many tokens");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 0, "tokensNum": 5},
  {"regionId": 2, "tokensNum": 1}
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
  {"regionId": 0, "tokensNum": 4},
  {"regionId": 2, "tokensNum": 1}
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


TEST("Select Race 2nd user");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "humans",
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

