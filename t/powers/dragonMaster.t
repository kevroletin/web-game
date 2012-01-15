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

init_logs('powers/dragonMaster');
ok( reset_server(123), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'farmland'], ['border', 'farmland'],
  ['border', 'hill'], ['border', 'hill']);


TEST("dragonAttack without selected power");
$user1->{_userId} = $user2->{_userId};
GO(
'{
  "action": "dragonAttack",
  "regionId": "1",
  "sid": ""
}'
,
'{
"result": "badStage"
}',
$user1 );


TEST("Select power");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "debug",
"power": "dragonMaster"
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
  "regionId": "0",
  "sid": ""
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(3, $user1);


TEST("dragonAttack on your region");
GO(
'{
  "action": "dragonAttack",
  "regionId": "0",
  "sid": ""
}'
,
'{
"result": "badRegion"
}',
$user1 );


TEST("dragonAttack");
GO(
'{
  "action": "dragonAttack",
  "regionId": "1",
  "sid": ""
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(2, $user1);


REGION_EXTRA_ITEM('dragon', 1, 1, $user1);


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 0, "tokensNum": 1},
  {"regionId": 1, "tokensNum": 1}
]
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


REGION_EXTRA_ITEM('dragon', 1, 1, $user1);


TEST("Select power");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "debug",
"power": "dragonMaster"
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
  "regionId": "2",
  "sid": ""
}'
,
'{
"result": "ok"
}',
$user2 );


TEST("dragonAttack");
GO(
'{
  "action": "dragonAttack",
  "regionId": "3",
  "sid": ""
}'
,
'{
"result": "ok"
}',
$user2 );


REGION_EXTRA_ITEM('dragon', 1, 3, $user2);


TEST("dragonAttack twice");
GO(
'{
  "action": "dragonAttack",
  "regionId": "3",
  "sid": ""
}'
,
'{
"result": "badStage"
}',
$user2 );


TEST("redeploy and leave dragon");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 2, "tokensNum": 1}
]
}'
,
'{
"result": "ok"
}',
$user2 );


REGION_EXTRA_ITEM('dragon', 0, 3, $user2);


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


REGION_EXTRA_ITEM('dragon', 0, 1, $user1);


done_testing();
