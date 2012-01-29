use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::square_map_two_users(
   ['farmland'], ['border', 'farmland'],   ['border', 'hill'], ['border', 'hill']
);

test('select race',
    {
      action => "selectGivenRace",
      power => "debug",
      race => "halflings",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_tokens_cnt(6, $user1);

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

test('conquer',
    {
      action => "conquer",
      regionId => 3,
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

test('redeploy',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 1,
          tokensNum => 1
        },
        {
          regionId => 2,
          tokensNum => 1
        },
        {
          regionId => 3,
          tokensNum => 1
        }
      ],
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
      coins => 3,
      result => "ok"
    },
    $user1 );

# SKIP
if (0) {

...;

HOLE_CNT(2, $user1);

IS_REG_HAVE_HOLE(1, 0, $user1);

IS_REG_HAVE_HOLE(1, 1, $user1);

IS_REG_HAVE_HOLE(0, 2, $user1);

IS_REG_HAVE_HOLE(0, 3, $user1);

test('select race',
    {
      action => "selectGivenRace",
      power => "debug",
      race => "halflings",
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

actions->check_tokens_cnt(6, $user2);

test('conquer land with hole',
    {
      action => "conquer",
      regionId => 1,
      sid => undef
    },
    {
      result => "regionIsImmune"
    },
    $user2 );

test('conquer',
    {
      action => "conquer",
      regionId => 4,
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

test('redeploy',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 4,
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

HOLE_CNT(1, $user2);

IS_REG_HAVE_HOLE(1, 0, $user1);

IS_REG_HAVE_HOLE(1, 1, $user1);

IS_REG_HAVE_HOLE(0, 2, $user1);

IS_REG_HAVE_HOLE(1, 3, $user1);

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
      coins => 3,
      result => "ok"
    },
    $user1 );

IS_REG_HAVE_HOLE(0, 0, $user1);

IS_REG_HAVE_HOLE(0, 1, $user1);

IS_REG_HAVE_HOLE(0, 2, $user1);

IS_REG_HAVE_HOLE(1, 3, $user1);

test('conquer',
    {
      action => "conquer",
      regionId => 2,
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

test('redeploy',
    {
      action => "redeploy",
      regions => [
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

IS_REG_HAVE_HOLE(0, 0, $user2);

IS_REG_HAVE_HOLE(1, 1, $user2);

IS_REG_HAVE_HOLE(0, 2, $user2);

IS_REG_HAVE_HOLE(0, 3, $user2);

};

done_testing;
