use warnings;
use strict;
use Tester::New;
use Tester::State;

actions()->reset_server();

my ($user1, $user2) = Tester::State::register_two_users_and_create_square_map(
  ['border', 'farmland'], ['border', 'farmland'],
  ['border', 'sea'], ['border', 'hill']);

test('createGame',
    {
      action => "createGame",
      ai => 1,
      gameDescr => "",
      gameName => "new-game",
      mapId => undef,
      sid => undef
    },
    {
      gameId => 1,
      result => "ok"
    },
    $user1);

test('setReadinessStatus',
    {
      action => "setReadinessStatus",
      isReady => 1,
      sid => undef,
    },
    {
      result => "ok"
    },
    $user1);

done_testing();
