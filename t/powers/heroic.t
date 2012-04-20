use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::square_map_two_users(
   ['border', 'farmland'], ['border', 'farmland'],   ['border', 'hill'], ['border', 'hill']
);

actions->compatibility_game_state_format($user1);

test('select power',
    {
      action => "selectGivenRace",
      power => "heroic",
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
      heroes => [
        {regionId => 1},
        {regionId => 2}
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

actions->check_reg(1, { currentRegionState => { hero => true } }, $user1);
actions->check_reg(2, { currentRegionState => { hero => true } }, $user1);

done_testing();
