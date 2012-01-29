use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

sub check_encampment {
    my ($cnt, $reg_num, $params) = @_;
    actions->check_reg($reg_num,
                       {
                        currentRegionState => {
                                               encampment => sub {
                                                   !defined $_[0] && $cnt == 0 ||
                                                   defined $_[0] && $cnt == $_[0]
                                               }
                                              }
                       },
                       $params, 3);
}

my ($user1, $user2) = Tester::State::square_map_two_users(
   ['border', 'farmland'], ['border', 'farmland'],   ['border', 'hill'], ['border', 'hill']
);

test('select power',
    {
      action => "selectGivenRace",
      power => "bivouacking",
      race => "debug",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_tokens_cnt(5, $user1);

test('conquer',
    {
      action => "conquer",
      regionId => 1,
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

test('conquer',
    {
      action => "conquer",
      regionId => 2,
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

test('redeploy',
    {
      action => "redeploy",
      encampments => [
        {
          encampmentsNum => 1,
          regionId => 1
        },
        {
          encampmentsNum => 5,
          regionId => 2
        }
      ],
      regions => [
        {
          regionId => 1,
          tokensNum => 1
        },
        {
          regionId => 2,
          tokensNum => 1
        }
      ],
      sid => undef
    },
    {
      result => "badEncampmentsNum"
    },
    $user1 );

check_encampment(0, 0, $user1);

check_encampment(0, 1, $user1);

test('redeploy',
    {
      action => "redeploy",
      encampments => [
        {
          encampmentsNum => 1,
          regionId => 1
        },
        {
          encampmentsNum => 1,
          regionId => 2
        }
      ],
      regions => [
        {
          regionId => 1,
          tokensNum => 1
        }
      ],
      sid => undef
    },
    {
      result => "badRegion"
    },
    $user1 );

check_encampment(0, 0, $user1);

check_encampment(0, 1, $user1);

test('redeploy',
    {
      action => "redeploy",
      encampments => [
        {
          encampmentsNum => 1,
          regionId => 1
        },
        {
          encampmentsNum => 4,
          regionId => 2
        }
      ],
      regions => [
        {
          regionId => 1,
          tokensNum => 1
        },
        {
          regionId => 2,
          tokensNum => 1
        }
      ],
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

check_encampment(1, 0, $user1);

check_encampment(4, 1, $user1);

test('finish turn',
    {
      action => "finishTurn",
      sid => undef
    },
    {
      coins => 2,
      result => "ok"
    },
    $user1 );

check_encampment(1, 0, $user1);

check_encampment(4, 1, $user1);

test('select power',
    {
      action => "selectGivenRace",
      power => "bivouacking",
      race => "debug",
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

#test('conquer strong region',
#    {
#      action => "conquer",
#      regionId => 2,
#      sid => undef,
#      dice => 0
#    },
#    {
#      result => "badTokensNum"
#    },
#    $user2 );

test('conquer',
    {
      action => "conquer",
      regionId => 1,
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

actions->check_tokens_cnt(1, $user2);

test('redeploy',
    {
      action => "redeploy",
      encampments => [
        {
          encampmentsNum => 1,
          regionId => 1
        }
      ],
      regions => [
        {
          regionId => 1,
          tokensNum => 1
        }
      ],
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

test('finish turn',
    {
      action => "finishTurn",
      sid => undef
    },
    {
      coins => 1,
      result => "ok"
    },
    $user2 );

test('decline 1st',
    {
      action => "decline",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

test('finish turn',
    {
      action => "finishTurn",
      sid => undef
    },
    {
      coins => 1,
      result => "ok"
    },
    $user1 );

done_testing();
