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
use Data::Dumper::Concise;


sub HOLE_CNT {
    my ($cnt, $params) = @_;
    my $usr_cmp = sub {
        my ($user) = @_;
        my $bad;
        if (!$user->{activeState}{holes_cnt}) {
            $bad = "holes_cnt not defined in response"
        } elsif ($user->{activeState}{holes_cnt} ne $cnt) {
            $bad = "in resp: $user->{activeState}{holes_cnt} != $cnt"
        }
        if ($bad) {
            return { res => 0, quick => 'bad halflings holes cnt',
                     long => "$bad\n" . Dumper($user) };
        }
        { res => 1, quick => 'ok' }
    };
    OK( check_user_state($usr_cmp, $params), "check holes cnt" );
}

sub IS_REG_HAVE_HOLE {
    my ($should_have, $reg_num, $params) = @_;
    my $reg_cmp = sub {
        my ($reg) = @_;
        if ($should_have == exists $reg->{extraItems}->{hole}) {
            return { res => 1, quick => 'ok' }
        }
        my $in_resp = exists $reg->{hole} ?
            "there is hole" : "there isn't hole";
        my $in_test = $should_have ? "should be" : "shouldn't be";
        { res => 0, quick => $in_resp,
          long => "$in_resp but it $in_test\n" . Dumper($reg) }
    };
    OK( check_region_state($reg_cmp, $reg_num, $params),
        "check halfling's hole in region" )
}


init_logs('races/halflings');
ok( reset_server(), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['farmland'], ['border', 'farmland'],
  ['border', 'hill'], ['border', 'hill']);


TEST("Select Race");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "halflings",
"power": "debug"
}'
,
'{
"result": "ok"
}',
$user1 );


TOKENS_CNT(6, $user1);


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



TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
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
"coins": "3"
}',
$user1 );


HOLE_CNT(2, $user1);

IS_REG_HAVE_HOLE(1, 0, $user1);

IS_REG_HAVE_HOLE(1, 1, $user1);

IS_REG_HAVE_HOLE(0, 2, $user1);

IS_REG_HAVE_HOLE(0, 3, $user1);


TEST("Select Race");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "halflings",
"power": "debug"
}'
,
'{
"result": "ok"
}',
$user2 );


TOKENS_CNT(6, $user2);


TEST("conquer land with hole");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 1
}'
,
'{
"result": "regionIsImmune"
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
"coins": "1"
}',
$user2 );


HOLE_CNT(1, $user2);

IS_REG_HAVE_HOLE(1, 0, $user1);

IS_REG_HAVE_HOLE(1, 1, $user1);

IS_REG_HAVE_HOLE(0, 2, $user1);

IS_REG_HAVE_HOLE(1, 3, $user1);


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
"coins": "3"
}',
$user1 );


IS_REG_HAVE_HOLE(0, 0, $user1);

IS_REG_HAVE_HOLE(0, 1, $user1);

IS_REG_HAVE_HOLE(0, 2, $user1);

IS_REG_HAVE_HOLE(1, 3, $user1);


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
$user2 );


TEST("redeploy");
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


IS_REG_HAVE_HOLE(0, 0, $user2);

IS_REG_HAVE_HOLE(1, 1, $user2);

IS_REG_HAVE_HOLE(0, 2, $user2);

IS_REG_HAVE_HOLE(0, 3, $user2);


done_testing();

