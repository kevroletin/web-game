use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::square_map_two_users(
   ['border', 'farmland'], ['border', 'farmland'],
   ['border', 'hill'], ['border', 'hill']
);

test('select race',
    {
      action => "selectGivenRace",
      power => "debug",
      race => "elves",
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

test('redeploy',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 1,
          tokensNum => 4
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
      coins => 1,
      result => "ok"
    },
    $user1 );

actions->check_tokens_cnt(2, $user1);

test('select race 2nd user',
    {
      action => "selectGivenRace",
      power => "debug",
      race => "elves",
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
      result => "ok"
    },
    $user2 );

actions->check_tokens_cnt(6, $user1);

done_testing();
