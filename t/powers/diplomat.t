use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::square_map_two_users(
   ['border', 'mountain'], ['border', 'farmland'],   ['border', 'hill'], ['border', 'hill']
);

test('selectfriend without selected power',
    {
      action => "selectFriend",
      sid => undef,
      userId => undef
    },
    {
      result => "badStage"
    },
    $user1 );

test('select power',
    {
      action => "selectGivenRace",
      power => "diplomat",
      race => "debug",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_tokens_cnt(5, $user1);

test('selectfriend before conquer',
    {
      action => "selectFriend",
      sid => undef,
      userId => undef
    },
    {
      result => "badStage"
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

test('selectfriend during conquer',
    {
      action => "selectFriend",
      sid => undef,
      userId => undef
    },
    {
      result => "badStage"
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

test('select self as friend',
    {
      action => "selectFriend",
      sid => undef,
      userId => undef
    },
    {
      result => "badUser"
    },
    $user1 );

test('selectfriend',
    {
      action => "selectFriend",
      sid => undef,
      userId => undef
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

test('select power',
    {
      action => "selectGivenRace",
      power => "diplomat",
      race => "debug",
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

test('conquer',
    {
      action => "conquer",
      regionId => 1,
      sid => undef
    },
    {
      result => "canNotAttackFriend"
    },
    $user2 );

test('conquer',
    {
      action => "conquer",
      regionId => 3,
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
          regionId => 3,
          tokensNum => 1
        },
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
      coins => 2,
      result => "ok"
    },
    $user2 );

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

done_testing();
