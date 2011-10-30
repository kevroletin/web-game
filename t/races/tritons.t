use strict;
use warnings;

use Test::More;

use JSON;

use lib '..';
use Tester;
use Tester::OK;
use Tester::Hooks;
use Tester::State;

init_logs('races/tritons');
ok( reset_server(), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'mountain', 'coast'], ['border', 'magic'],
  ['border', 'hill'], ['border', 'hill']);


TEST("Select Race");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "tritons",
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
  "regionId": 1
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


TEST("redeploy too many tokens");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 0, "tokensNum": 4},
  {"regionId": 1, "tokensNum": 1},
  {"regionId": 2, "tokensNum": 1},
  {"regionId": 3, "tokensNum": 1}
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
  {"regionId": 0, "tokensNum": 3},
  {"regionId": 1, "tokensNum": 1},
  {"regionId": 2, "tokensNum": 1},
  {"regionId": 3, "tokensNum": 1}
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
"coins": "4"
}',
$user1 );


done_testing();

