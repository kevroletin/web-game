package Tester::State;

use strict;
use warnings;

use Test::More;

use JSON;
use Data::Dumper::Concise;

use lib '..';
use Game::Constants;
use Tester::New;

use Carp;
$SIG{__DIE__} = \&Carp::confess;
$SIG{__WARN__} = \&Carp::confess;
$SIG{INT} = \&Carp::confess;


sub register_two_users_and_create_square_map {
    my ($d_1, $d_2, $d_3, $d_4, $c1, $c2, $c3, $c4) = @_;
    $$_ ||= 0 for \$c1, \$c2, \$c3, \$c4;

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

    #+---------------+----------------+
    #|0              |1               |
    #| border        |  border        |
    #| coast         |  forest        |
    #| mountain      |     /|\        |
    #|   .           |     /|\        |
    #|   |\_         |    /_|_\       |
    #| .-   \-.      |      |         |
    #+---------------+------|---------+
    #|2              |3               |
    #| border        | border         |
    #| sea           | coast          |
    #|               | hill           |
    #|               |________________|
    #| ~  ~  ~  ~    |''''''''''''''''|
    #|  ~   ~  ~     |''''''''''''''''|
    #| ~  ~  ~  ~    |''''''''''''''''|
    #+---------------+----------------+

test("upload map",
    {
      action => "uploadMap",
      mapName => "uploadedMap",
      turnsNum => 10,
      playersNum => 2,
      regions => [
        {
          adjacent => [ 2, 3 ],
          coordinates => [
            [0, 0],
            [0, 100],
            [100, 100],
            [100, 0]
          ],
          raceCoords => [10, 10],
          powerCoords => [60, 10],
          landDescription => [ @$d_1 ],
          population => $c1
        },
        {
          adjacent => [ 1, 4 ],
          coordinates => [
            [0, 100],
            [0, 200],
            [100, 200],
            [100, 100]
          ],
          raceCoords => [10, 110],
          powerCoords => [60, 110],
          landDescription => [ @$d_2 ],
          population => $c2
        },
        {
          adjacent => [ 1, 4 ],
          coordinates => [
            [100, 0],
            [100, 100],
            [200, 100],
            [200, 0]
          ],
          raceCoords => [110, 10],
          powerCoords => [110, 60],
          landDescription => [ @$d_3 ],
          population => $c3
        },
        {
          adjacent => [ 2, 3 ],
          coordinates => [
            [100, 100],
            [100, 200],
            [200, 200],
            [200, 100]
          ],
          raceCoords => [110, 110],
          powerCoords => [60, 60],
          landDescription => [ @$d_4 ],
          population => $c4
        }
      ]
    },
    {
    result => 'ok',
    mapId => undef
    },
    $user1 );

    $user1->{info}{number_in_game} = 0;
    $user2->{info}{number_in_game} = 1;

    ($user1, $user2)
}

sub __compliment_token_badges {
    my ($tok_b) = @_;
    my %r = map { ($_ => 1) } @{Game::Constants::races()};
    my %p = map { ($_ => 1) } @{Game::Constants::powers()};
    delete $r{$_} for @{$tok_b->{races}};
    delete $p{$_} for @{$tok_b->{powers}};
    push @{$tok_b->{races}}, ucfirst($_) for sort keys %r;
    push @{$tok_b->{powers}}, ucfirst($_) for sort keys %p;
    $tok_b;
}

sub square_map_two_users {
    if ($ENV{debug_loading}) {
        __square_map_two_users_debug_state(@_)
    } else {
        __square_map_two_users(@_);
    }
}

sub __square_map_two_users {
    my $token_badges = ref($_[-1]) eq 'HASH' ? pop @_ : undef;
    my ($user1, $user2) =
        register_two_users_and_create_square_map(@_);

test('create game 1st user',
    {
      action => 'createGame',
      sid => undef,
      gameName => 'game1',
      gameDescr => 'game1 descr',
      mapId =>  undef
    },
    {
      result => 'ok',
      gameId => undef
    },
    $user1 );

    $user2->{data}{gameId} = $user1->{data}{gameId};

=begin comment

test('join game',
    {
      action => "joinGame",
      gameId => undef,
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

=cut comment

test('join game 2nd user',
    {
      action => "joinGame",
      gameId => undef,
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

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

    my $req = {
               action => "setReadinessStatus",
               isReady => 1,
               sid => undef
              };
    if (defined $token_badges) {
        __compliment_token_badges($token_badges);
        $req->{visibleRaces} = $token_badges->{races};
        $req->{visibleSpecialPowers} = $token_badges->{powers};
    }
test('2nd user ready',
     $req,
    {
      result => "ok"
    },
    $user2 );

=begin comment

test('1st getuserinfo',
    {
      action => "getUserInfo",
      sid => undef
    },
    {
      activeGame => undef,
      result => "ok",
      userId => undef,
      username => "user1"
    },
    $user1 );

test('2nd getuserinfo',
    {
      action => "getUserInfo",
      sid => undef
    },
    {
      activeGame => undef,
      result => "ok",
      userId => undef,
      username => "user2"
    },
    $user2 );

=cut comment

    ($user1, $user2)
}

sub __square_map_two_users_debug_state {
    my @map = @_;
    my ($user1, $user2);

    my $check_game_loading = sub {
        $_ = actions->save_game($user1);
        my $state = $_->{resp};

        tests_context()->{show_only_errors} = 1;
        my ($user1_new, $user2_new) =
            register_two_users_and_create_square_map(@map);
        %$user1 = %$user1_new;
        %$user2 = %$user2_new;

        test('load state',
             {
              action => 'loadGame',
              sid => $user1->{data}{sid},
              gameName => 'loaded game',
              gameState => $state->{gameState}
             },
             {
              result => 'ok'
             },
             $user1);
        $user2->{data}{gameId} = $user1->{data}{gameId};

        tests_context()->{show_only_errors} = 0;

        my ($res, $c) = test('check new state',
             {
              action => 'saveGame',
              sid => undef
             },
             $state,
             $user1,
             { diff_method => 'EXACT',
               stack_level => 8 });


        exit() unless $res->{res}
    };

    ($user1, $user2) = __square_map_two_users(@map);

    before_request_hook( $check_game_loading );

    ($user1, $user2)
}


1;
