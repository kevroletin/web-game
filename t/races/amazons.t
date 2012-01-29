use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'farmland'], ['border', 'farmland'],
  ['border', 'sea'], ['border', 'hill']);

test('select race',
    {
      action => "selectGivenRace",
      power => "debug",
      race => "amazons",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_tokens_cnt(6, $user1);

test('conquer sea',
    {
      action => "conquer",
      regionId => 3,
      sid => undef
    },
    {
      result => "badRegion"
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

actions->check_tokens_cnt(6, $user1);

test('redeploy',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 1,
          tokensNum => 5
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

actions->check_tokens_cnt(0, $user1);

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

test('select race',
    {
      action => "selectGivenRace",
      power => "debug",
      race => "amazons",
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

actions->check_tokens_cnt(6, $user2);

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

actions->check_tokens_cnt(3, $user2);

actions->check_tokens_cnt(4, $user1);

test('defend',
    {
      action => "defend",
      regions => [
        {
          regionId => 2,
          tokensNum => 4
        }
      ],
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
          tokensNum => 6
        }
      ],
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

actions->check_tokens_cnt(0, $user2);

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
