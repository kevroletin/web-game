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
      power => "fortified",
      race => "debug",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_tokens_cnt(3, $user1);

test('conquer 1st',
    {
      action => "conquer",
      regionId => 1,
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_reg(3, { currentRegionState => { fortified => null_or_val_checker(false)} }, $user1);

test('redeploy on empty region 1st',
    {
      action => "redeploy",
      fortified => {
        regionId => 3
      },
      regions => [
        {
          regionId => 2,
          tokensNum => 1
        }
      ],
      sid => undef
    },
    {
      result => "badRegion"
    },
    $user1 );

actions->check_reg(3, { currentRegionState => { fortified => null_or_val_checker(false)} }, $user1);

test('redeploy 1st',
    {
      action => "redeploy",
      fortified => {
        regionId => 1
      },
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
    $user1 );

actions->check_reg(1, { currentRegionState => { fortified => true } }, $user1);

test('finish turn: check extra coins',
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
      power => "fortified",
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
      regionId => 3,
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
          tokensNum => 2
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

actions->check_reg(1, { currentRegionState => { fortified => true } }, $user1);

test('finish turn: no extra tokens',
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
