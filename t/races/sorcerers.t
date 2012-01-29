use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::square_map_two_users(
   ['border', 'farmland'], ['border', 'farmland'],   ['border', 'hill'], ['border', 'hill']
);

test('select race',
    {
      action => "selectGivenRace",
      power => "debug",
      race => "sorcerers",
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

actions->check_tokens_cnt(1, $user1);

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

actions->check_tokens_cnt(3, $user1);

test('enchant before select race',
    {
      action => "enchant",
      regionId => 2,
      sid => undef
    },
    {
      result => "badStage"
    },
    $user2 );

test('select race',
    {
      action => "selectGivenRace",
      power => "debug",
      race => "sorcerers",
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

test('enchant not adjacent',
    {
      action => "enchant",
      regionId => 2,
      sid => undef
    },
    {
      result => "badRegion"
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

test('enchant not adjacent',
    {
      action => "enchant",
      regionId => 2,
      sid => undef
    },
    {
      result => "badRegion"
    },
    $user2 );

test('enchant',
    {
      action => "enchant",
      regionId => 1,
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
          regionId => 1,
          tokensNum => 2
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
    $user2 );

actions->check_tokens_cnt(3, $user2);

actions->check_tokens_cnt(3, $user1);

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

test('enchant region with 2 tokens',
    {
      action => "enchant",
      regionId => 1,
      sid => undef
    },
    {
      result => "badRegion"
    },
    $user1 );

test('conquer',
    {
      action => "conquer",
      regionId => 4,
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
          regionId => 2,
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

test('enchant',
    {
      action => "enchant",
      regionId => 2,
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

test('enchant twice',
    {
      action => "enchant",
      regionId => 1,
      sid => undef
    },
    {
      result => "badStage"
    },
    $user2 );

done_testing();
