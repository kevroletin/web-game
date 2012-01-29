use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::square_map_two_users(
   ['border', 'hill'], ['border', 'farmland'],   ['border', 'forest'], ['border', 'forest']
);

test('select power',
    {
      action => "selectGivenRace",
      power => "mounted",
      race => "debug",
      sid => undef
    },
    {
      result => "ok"
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

done_testing();
