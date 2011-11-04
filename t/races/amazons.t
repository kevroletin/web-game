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

init_logs('races/amazons');
ok( reset_server(), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'farmland'], ['border', 'farmland'],
  ['border', 'sea'], ['border', 'hill']);


TEST("Select Race");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "amazons",
"power": "debug"
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(6, $user1);


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


TOKENS_CNT(6, $user1);


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


TOKENS_CNT(6, $user1);


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 0, "tokensNum": 5},
  {"regionId": 1, "tokensNum": 1}
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
"coins": "2"
}',
$user1 );


TEST("Select Race");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "amazons",
"power": "debug"
}'
,
'{
"result": "ok"
}',
$user2 );


TOKENS_CNT(6, $user2);


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
$user2 );


TOKENS_CNT(3, $user2);


TOKENS_CNT(4, $user1);


TEST("defend");
GO(
'{
  "action": "defend",
  "sid": "",
  "regions": [{"regionId": 1, "tokensNum": 4}]
}'
,
'{
"result":"ok"
}',
$user1 );


TOKENS_CNT(0, $user1);


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 0, "tokensNum": 6}
]
}'
,
'{
"result": "ok"
}',
$user2 );


TOKENS_CNT(0, $user2);


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


done_testing();
