
use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

=begin comment

record();

test('',
     { action => 'getGameState', sid => '5' },
     { result => 'ok' } );

tests_context()->{use_text_diff} = 1;

#replay('http://server.lena/small_worlds');

=cut comment

    my @fields_to_save = ('sid', 'gameId', 'mapId', 'coins',
                          'activeGame', 'userId');
    my ($user1, $user2) =
        map { hooks_sync_values(@fields_to_save) } 1, 2;

test('reset server', {action => 'resetServer'}, {result => 'ok'} );

test('register 1st user',
    {
      action => "register",
      password => "password1",
      username => "user1"
    },
    {
      result => "ok"
    });

test('login 1st user',
    {
      action => "login",
      password => "password1",
      username => "user1"
    },
    {
      result => "ok",
      sid => undef,
      userId => undef
    },
    $user1 );

test('register 2nd user',
    {
      action => "register",
      password => "password2",
      username => "user2"
    },
    {
      result => "ok"
    });


    $user1->{info}{number_in_game} = 0;
    $user2->{info}{number_in_game} = 1;

test('login 2nd user',
    {
      action => "login",
      password => "password2",
      username => "user2"
    },
    {
      result => "ok",
      sid => undef,
      userId => undef
    },
    $user2 );

test('create default maps',
     { action => 'createDefaultMaps' }, {result => 'ok'});

test('create game 1st user',
    {
      action => 'createGame',
      sid => undef,
      gameName => 'game1',
      gameDescr => 'game1 descr',
      mapId =>  3
    },
    {
      result => 'ok',
      gameId => undef
    },
    $user1 );

test('1st user ready',
    {
      action => "setReadinessStatus",
      isReady => 1,
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

test('join game 2nd user',
    {
      action => "joinGame",
      gameId => $user1->{data}{gameId},
      sid    => undef
    },
    {
      result => "ok"
    },
    $user2 );

exit();

test('2nd user ready',
    {
      action => "setReadinessStatus",
      isReady => 1,
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );



done_testing();

