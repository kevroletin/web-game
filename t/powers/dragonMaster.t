use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::square_map_two_users(
   ['border', 'farmland'], ['border', 'farmland'],   ['border', 'hill'], ['border', 'hill']
);

test('dragonattack without selected power',
    {
      action => "dragonAttack",
      regionId => 2,
      sid => undef
    },
    {
      result => "badStage"
    },
    $user1 );

test('select power',
    {
      action => "selectGivenRace",
      power => "dragonMaster",
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

actions->check_tokens_cnt(3, $user1);

test('dragonattack on your region',
    {
      action => "dragonAttack",
      regionId => 1,
      sid => undef
    },
    {
      result => "badRegion"
    },
    $user1 );

test('dragonattack',
    {
      action => "dragonAttack",
      regionId => 2,
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_tokens_cnt(2, $user1);

actions->check_reg(1, {currentRegionState => {'dragon' => true}}, $user1);

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

actions->check_reg(1, {currentRegionState => {'dragon' => true}}, $user1);

test('select power',
    {
      action => "selectGivenRace",
      power => "dragonMaster",
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

test('dragonattack',
    {
      action => "dragonAttack",
      regionId => 4,
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

actions->check_reg(3, {currentRegionState => {'dragon' => true}}, $user1);

test('dragonattack twice',
    {
      action => "dragonAttack",
      regionId => 4,
      sid => undef
    },
    {
      result => "badStage"
    },
    $user2 );

test('redeploy and leave dragon',
    {
      action => "redeploy",
      regions => [
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
    $user2 );

actions->check_reg(1, {currentRegionState => {'dragon' => null_or_val_checker(false) }}, $user1);

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

actions->check_reg(1, {currentRegionState => {'dragon' => null_or_val_checker(false) }}, $user1);

done_testing();
