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

init_logs('powers/fortified');
ok( reset_server(), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'farmland'], ['border', 'farmland'],
  ['border', 'hill'], ['border', 'hill']);


TEST("Select power");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "debug",
"power": "fortified"
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(3, $user1);


TEST("conquer 1st");
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


REGION_EXTRA_ITEM('fortified', 0, 0,  $user1);


TEST("redeploy on empty region 1st");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 2, "tokensNum": 1}
],
"fortified": {"regionId": 3}
}'
,
'{
"result": "badRegion"
}',
$user1 );


REGION_EXTRA_ITEM('fortified', 0, 2,  $user1);


TEST("redeploy 1st");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 1, "tokensNum": 1}
],
"fortified": {"regionId": 1}
}'
,
'{
"result": "ok"
}',
$user1 );


REGION_EXTRA_ITEM('fortified', 1, 0,  $user1);


TEST("finish turn: check extra coins");
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


TEST("Select power");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "debug",
"power": "fortified"
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
  {"regionId": 3, "tokensNum": 2}
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


REGION_EXTRA_ITEM('fortified', 1, 0,  $user1);


TEST("finish turn: no extra tokens");
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
$user1 );


# TODO: try to attack region with fort, try to leave reg
# with fort, try to place too many forts

done_testing();

