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

init_logs('powers/diplomat');
ok( reset_server(123), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'mountain'], ['border', 'farmland'],
  ['border', 'hill'], ['border', 'hill']);


TEST("selectFriend without selected power");
my $user1_id = $user1->{_userId};
$user1->{_userId} = $user2->{_userId};
GO(
'{
  "action": "selectFriend",
  "userId": "",
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
"power": "diplomat"
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(5, $user1);


TEST("selectFriend before conquer");
GO(
'{
  "action": "selectFriend",
  "userId": "",
  "sid": ""
}'
,
'{
"result": "badStage"
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


TEST("selectFriend during conquer");
GO(
'{
  "action": "selectFriend",
  "userId": "",
  "sid": ""
}'
,
'{
"result": "badStage"
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


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 1, "tokensNum": 1},
  {"regionId": 2, "tokensNum": 1}
]
}'
,
'{
"result": "ok"
}',
$user1 );


TEST("select self as Friend");
$user1->{_userId} = $user1_id;
GO(
'{
  "action": "selectFriend",
  "userId": "",
  "sid": ""
}'
,
'{
"result": "badUser"
}',
$user1 );


TEST("selectFriend");
$user1->{_userId} = $user2->{_userId};
GO(
'{
  "action": "selectFriend",
  "userId": "",
  "sid": ""
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


TEST("Select power");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "debug",
"power": "diplomat"
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
  "regionId": 1
}'
,
'{
"result": "canNotAttackFriend"
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


TEST("conquer");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 4
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
  {"regionId": 3, "tokensNum": 1},
  {"regionId": 4, "tokensNum": 1}
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
"coins": "2"
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
$user1 );


# TODO: check gameState, make multiple turns

done_testing();

