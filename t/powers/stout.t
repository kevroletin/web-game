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

init_logs('powers/stout');
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
"power": "stout"
}'
,
'{
"result": "ok"
}',
$user1 );

my $checker = sub {
    my ($user) = @_;
    { res => defined $user->{activeRace} }
};

OK( check_user_state($checker, $user1),
    'check if user in decline' );


TOKENS_CNT(4, $user1);


TEST("conquer 1st");
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


TEST("redeploy 1st");
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


TEST("decline after redeploy");
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
$user1 );

$checker = sub {
    my ($user) = @_;
    { res => !defined $user->{activeRace} }
};

OK( check_user_state($checker, $user1),
    'check if user in decline' );

# TODO: more tests. Check if we made decline after coins
# computing

done_testing();
