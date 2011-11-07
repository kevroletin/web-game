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

init_logs('powers/commando');
ok( reset_server(), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'mountain'], ['border', 'farmland'],
  ['border', 'hill'], ['border', 'hill']);


TEST("Select power");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "debug",
"power": "commando"
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(4, $user1);


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


TOKENS_CNT(2, $user1);


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


done_testing();

