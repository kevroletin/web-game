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

init_logs('races/orcs');
ok( reset_server(), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'farmland'], ['border', 'farmland'],
  ['border', 'hill'], ['border', 'hill']);


TEST("Select Race");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "orcs",
"power": "debug"
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(5, $user1);


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


TOKENS_CNT(1, $user1);


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 0, "tokensNum": 1},
  {"regionId": 1, "tokensNum": 4}
]
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(0, $user1);


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

