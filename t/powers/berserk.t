use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::square_map_two_users(
   ['border', 'mountain'], ['border', 'farmland'],   ['border', 'hill'], ['border', 'hill']
);

test('select power',
    {
      action => "selectGivenRace",
      power => "berserk",
      race => "debug",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_tokens_cnt(4, $user1);

test('throwdice',
    {
      action => "throwDice",
      sid => undef,
      dice => 2,
    },
    {
      dice => 2,
      result => "ok"
    },
    $user1 );

test('throwdice twice',
    {
      action => "throwDice",
      sid => undef
    },
    {
      result => "badStage"
    },
    $user1 );

actions->check_tokens_cnt(4, $user1);

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

actions->check_tokens_cnt(3, $user1);

test('throwdice',
    {
      action => "throwDice",
      sid => undef,
      dice => 3
    },
    {
      dice => 3,
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

actions->check_tokens_cnt(2, $user1);

test('throwdice',
    {
      action => "throwDice",
      sid => undef,
      dice => 0,
    },
    {
      dice => 0,
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

actions->check_tokens_cnt(0, $user1);

test('throwdice without tokens',
    {
      action => "throwDice",
      sid => undef
    },
    {
      result => "badStage"
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
          tokensNum => 2
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

test('throwdice without active race',
    {
      action => "throwDice",
      sid => undef
    },
    {
      result => "badStage"
    },
    $user2 );

done_testing();
