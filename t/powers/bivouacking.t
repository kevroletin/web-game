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

init_logs('powers/bivouacking');
ok( reset_server(), 'reset server' );

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'farmland'], ['border', 'farmland'],
  ['border', 'hill'], ['border', 'hill']);

sub CHECK_ENCAMPMENT {
    my ($cnt, $reg_num, $params) = @_;
    my $reg_cmp = sub {
        my ($reg) = @_;
        my $enc = $reg->{extraItems}->{encampment};
        if ($cnt == 0 && !defined $enc || $cnt == $enc) {
            return { res => 1, quick => 'ok' }
        }
        my $in_resp = defined $enc ?
            "encampment in resp $enc != $cnt " :
            "there isn't encampment";
        { res => 0, quick => $in_resp,
          long => "$in_resp\n" . Dumper($reg) }
    };
    OK( check_region_state($reg_cmp, $reg_num, $params),
        "check encampment cnt" )
}


TEST("Select power");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "debug",
"power": "bivouacking"
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


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 1, "tokensNum": 1},
  {"regionId": 2, "tokensNum": 1}
],
"encampments": [
  {"regionId": 1, "encampmentsNum": 1},
  {"regionId": 2, "encampmentsNum": 5}
]
}'
,
'{
"result": "badEncampmentsNum"
}',
$user1 );


CHECK_ENCAMPMENT(0, 0, $user1);

CHECK_ENCAMPMENT(0, 1, $user1);


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 1, "tokensNum": 1}
],
"encampments": [
  {"regionId": 1, "encampmentsNum": 1},
  {"regionId": 2, "encampmentsNum": 1}
]
}'
,
'{
"result": "badRegion"
}',
$user1 );


CHECK_ENCAMPMENT(0, 0, $user1);

CHECK_ENCAMPMENT(0, 1, $user1);


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 1, "tokensNum": 1},
  {"regionId": 2, "tokensNum": 1}
],
"encampments": [
  {"regionId": 1, "encampmentsNum": 1},
  {"regionId": 2, "encampmentsNum": 4}
]
}'
,
'{
"result": "ok"
}',
$user1 );


CHECK_ENCAMPMENT(1, 0, $user1);

CHECK_ENCAMPMENT(4, 1, $user1);


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


CHECK_ENCAMPMENT(1, 0, $user1);

CHECK_ENCAMPMENT(4, 1, $user1);


TEST("Select power");
GO(
'{
"action": "selectGivenRace",
"sid": "",
"race": "debug",
"power": "bivouacking"
}'
,
'{
"result": "ok"
}',
$user2 );


TEST("conquer strong region");
GO(
'{
  "action": "conquer",
  "sid": "",
  "regionId": 2
}'
,
'{
"result": "noEnouthUnits"
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
"result": "ok"
}',
$user2 );


TOKENS_CNT(1, $user2);


TEST("redeploy");
GO(
'{
"action": "redeploy",
"sid": "",
"regions": [
  {"regionId": 1, "tokensNum": 1}
],
"encampments": [
  {"regionId": 1, "encampmentsNum": 1}
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
$user1 );


# TODO: check if encampment will desappear after
# region ocupation

done_testing();

