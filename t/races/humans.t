use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::square_map_two_users(
   ['border', 'farmland'], ['border', 'farmland'],   ['border', 'hill'], ['border', 'hill']
);

tests_context()->{use_text_diff} = 1;

test('select race',
    {
      action => "selectGivenRace",
      power => "debug",
      race => "humans",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

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
      regionId => 3,
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

test('redeploy too many tokens',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 1,
          tokensNum => 5
        },
        {
          regionId => 3,
          tokensNum => 1
        }
      ],
      sid => undef
    },
    {
      result => "notEnoughTokensForRedeployment"
    },
    $user1 );

test('redeploy',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 1,
          tokensNum => 4
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

test('select race 2nd user',
    {
      action => "selectGivenRace",
      power => "debug",
      race => "humans",
      sid => undef
    },
    {
      result => "ok"
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
      coins => 2,
      result => "ok"
    },
    $user1 );

test('decline 2nd',
    {
      action => "decline",
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

done_testing();
