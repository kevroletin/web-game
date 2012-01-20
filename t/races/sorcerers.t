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

init_logs('races/sorcerers');
ok( reset_server(), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'farmland'], ['border', 'farmland'],
  ['border', 'hill'], ['border', 'hill']);


TEST("Select Race");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "sorcerers",
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


TOKENS_CNT(1, $user1);


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


TOKENS_CNT(3, $user1);


TEST("enchant before select race");
GO(
'{
"action": "enchant",
"sid": "",
"regionId": 2
}'
,
'{
"result": "badStage"
}',
$user2 );


TEST("Select Race");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "sorcerers",
"power": "debug"
}'
,
'{
"result": "ok"
}',
$user2 );


TEST("enchant not adjacent");
GO(
'{
"action": "enchant",
"sid": "",
"regionId": 2
}'
,
'{
"result": "badRegion"
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


TEST("enchant not adjacent");
GO(
'{
"action": "enchant",
"sid": "",
"regionId": 2
}'
,
'{
"result": "badRegion"
}',
$user2 );


TEST("enchant");
GO(
'{
"action": "enchant",
"sid": "",
"regionId": 1
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
  {"regionId": 1, "tokensNum": 2},
  {"regionId": 3, "tokensNum": 1}
]
}'
,
'{
"result": "ok"
}',
$user2 );


TOKENS_CNT(3, $user2);

TOKENS_CNT(3, $user1);


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


TEST("enchant region with 2 tokens");
GO(
'{
"action": "enchant",
"sid": "",
"regionId": 1
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
  "regionId": 4
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
  {"regionId": 2, "tokensNum": 1},
  {"regionId": 4, "tokensNum": 1}
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


TEST("enchant");
GO(
'{
"action": "enchant",
"sid": "",
"regionId": 2
}'
,
'{
"result": "ok"
}',
$user2 );


TEST("enchant twice");
GO(
'{
"action": "enchant",
"sid": "",
"regionId": 1
}'
,
'{
"result": "badStage"
}',
$user2 );


done_testing();

