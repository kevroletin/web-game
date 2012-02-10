use strict;
use warnings;

use lib '..';
use lib '../..';

use Tester::State;
use Tester::New;

delete $ENV{debug_loading};

my ($user1, $user2) = Tester::State::square_map_two_users(
  ['border', 'farmland'], ['border', 'farmland'],
  ['border', 'sea'], ['border', 'hill'],
  {
    races => ["Ratmen", "Elves"],
    powers => ["Flying", "Forest"]
  });

test('check what race not selected',
     {
      action => 'getGameState',
      gameId => undef
     },
     {
      result => 'ok',
      gameState => { raceSelected => false }
     },
     $user1);

test('select race 1st user',
     {
      action => "selectRace",
      sid => undef,
      position => 1
     },
     { result => 'ok' },
     $user1);

test('check what race selected',
     {
      action => 'getGameState',
      gameId => undef
     },
     {
      result => 'ok',
      gameState => { raceSelected => true }
     },
     $user1);

test('conquer',
     {
      action => 'conquer',
      regionId => 1,
      sid => undef
     },
     { result => 'ok' },
     $user1);

test('redeploy',
     {
      action => "redeploy",
      regions => [{ regionId => 1, tokensNum => 7 }],
      sid => undef
     },
     { result => "ok" },
     $user1 );

test('finish turn',
     {
      action => "finishTurn",
      sid => undef
     },
     { result => 'ok'},
     $user1 );

test('check what race not selected',
     {
      action => 'getGameState',
      gameId => undef
     },
     {
      result => 'ok',
      gameState => { raceSelected => false }
     },
     $user2);

test('select race 2nd user',
     {
      action => "selectRace",
      sid => undef,
      position => 1
     },
     { result => 'ok' },
     $user2);

test('check what race selected',
     {
      action => 'getGameState',
      gameId => undef
     },
     {
      result => 'ok',
      gameState => { raceSelected => true }
     },
     $user2);

test('conquer',
     {
      action => 'conquer',
      regionId => 2,
      sid => undef
     },
     { result => 'ok' },
     $user2);

test('redeploy',
     {
      action => "redeploy",
      regions => [{ regionId => 2, tokensNum => 7 }],
      sid => undef
     },
     { result => "ok" },
     $user2);

test('finish turn',
     {
      action => "finishTurn",
      sid => undef
     },
     { result => 'ok'},
     $user2);

done_testing();
