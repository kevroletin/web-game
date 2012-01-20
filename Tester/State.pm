package Tester::State;

use strict;
use warnings;

use Test::More;

use JSON;
use Data::Compare;
use Data::Dumper::Concise;

use lib '..';
use Tester;
#use Tester::OK;
use Tester::Hooks;
use Exporter::Easy (
    EXPORT => [ qw( get_game_state ) ],
);


my ($descr, $in, $out, $hooks) = (('') x 4);

my $ok = 1;
my $fail_test;

sub get_game_state {
    my ($user) = @_;
    my $state;
    my $in = { action => 'getGameState',
               sid => $user->{_sid} };
    my $out = { result => 'ok' };
    my $h = sub {
        $state = $_[2];
        defined $state->{result} && $state->{result} eq 'ok'
    };
    my $ok = json_custom_compare_test($h, to_json($in), '{}', {});
    ok( $ok, 'Get game state' );

    write_msg("\n*** Get game state  ***:", $ok);
    write_msg(Dumper($state)) unless $ok;
    exit unless $ok;
    $state
}

sub OK {
    $ok &&= $_[0]->{res};
    $fail_test = \@_ unless $ok;
#    write_msg("\n*** $_[1]  ***:  ", $_[0]->{quick} . "\n");
#    write_msg($_[0]->{long} . "\n") if $_[0]->{long};
}

sub FINISH {
    my $descr = $fail_test;
#    $descr = "Create 2x2 map with 2 users" unless $descr;
    ok($ok, 'Create 2x2 map with 2 users');
    if ($fail_test) {
        $_ = $fail_test;
        write_msg("\n*** $_->[1]  ***:  ", $_->[0]->{quick} . "\n");
        write_msg($_->[0]->{long} . "\n") if $_->[0]->{long};
    }
}

sub GO {
    $in = $_[0] if $_[0];
    $out = $_[1] if $_[1];
    $hooks = $_[2] if $_[2];
    write_log($descr);
    OK( json_compare_test($in, $out, $hooks), $descr );
}

sub IN { if ($_[0]) { $in = $_[0] } $in  }

sub OUT { if ($_[0]) { $out = $_[0] } $out }

sub HOOKS { if ($_[0]) { $hooks = $_[0] } $hooks }

sub TEST { if ($_[0]) { $descr = $_[0] } $descr }


sub register_two_users_and_create_square_map {
    my ($d_1, $d_2, $d_3, $d_4, $c1, $c2, $c3, $c4) = @_;
    $$_ ||= 0 for \$c1, \$c2, \$c3, \$c4;

    my @fields_to_save = ('sid', 'gameId', 'mapId', 'coins',
                          'activeGame', 'userId');
    my $user1 = params_same(@fields_to_save);
    my $user2 = params_same(@fields_to_save);

    TEST("register 1st user");
    $user1->{_number_in_game} = 0;
    GO(
    '{
    "action": "register",
    "username": "user1",
    "password": "password1"
    }'
    ,
    '{
    "result": "ok"
    }'
    , {} );


    TEST("login 1st user");
    GO(
    '{
    "action": "login",
    "username": "user1",
    "password": "password1"
    }'
    ,
    '{
    "result": "ok",
    "sid": "",
    "userId": ""
    }'
    , $user1 );


    TEST("register 2nd user");
    $user2->{_number_in_game} = 1;
    GO(
    '{
    "action": "register",
    "username": "user2",
    "password": "password2"
    }'
    ,
    '{
    "result": "ok"
    }'
    , {} );


    TEST("login 2nd user");
    GO(
    '{
    "action": "login",
    "username": "user2",
    "password": "password2"
    }'
    ,
    '{
    "result": "ok",
    "sid": "",
    "userId": ""
    }'
    , $user2 );


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

    TEST("upload map");
    GO(to_json({
      action => "uploadMap",
      mapName => "uploadedMap",
      turnsNum => "10",
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
          bonusCoords => [10, 60],
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
          landDescription => [ @$d_4 ],
          population => $c4
        }
      ]
    }),
    '{
    "result": "ok",
    "mapId": ""
    }',
    $user1 );

    ($user1, $user2)
}

sub square_map_two_users {
    my ($user1, $user2) =
        register_two_users_and_create_square_map(@_);

    TEST("Create Game 1st user");
    GO(
    '{
    "action": "createGame",
    "sid": "",
    "gameName": "game1",
    "gameDescr": "game1 descr",
    "mapId": ""
    }',
    '{
    "result": "ok",
    "gameId": ""
    }',
    $user1 );

=begin comment

    TEST("Join Game");
    GO(
    '{
    "action": "joinGame",
    "sid": "",
    "gameId": ""
    }'
    ,
    '{
    "result": "ok"
    }',
    $user1 );

=cut comment

    TEST("Join Game 2nd user");
    $user2->{_gameId} = $user1->{_gameId};
    GO(
    '{
    "action": "joinGame",
    "sid": "",
    "gameId": ""
    }'
    ,
    '{
    "result": "ok"
    }',
    $user2 );

    TEST("1st user ready");
    GO(
    '
    {
      "action": "setReadinessStatus",
      "sid": "",
      "isReady": 1
    }'
    ,
    '{
    "result": "ok"
    }',
    $user1 );

    TEST("2nd user ready");
    GO(
    '
    {
      "action": "setReadinessStatus",
      "sid": "",
      "isReady": 1
    }'
    ,
    '{
    "result": "ok"
    }',
    $user2 );

    TEST("1st getUserInfo");
    GO(
    '{
      "action": "getUserInfo",
      "sid": ""
    }'
    ,
    '{
      "userId" : "",
      "activeGame" : "",
      "result" : "ok",
      "username" : "user1"
    }',
    $user1 );

    TEST("2nd getUserInfo");
    GO(
    '{
      "action": "getUserInfo",
      "sid": ""
    }'
    ,
    '{
      "userId" : "",
      "activeGame" : "",
      "result" : "ok",
      "username" : "user2"
    }',
    $user2 );


    FINISH();

    ($user1, $user2)
}

sub square_map_two_users_debug_state {
    my $p_user1 = \$_[0];
    my $p_user2 = \$_[1];
    my ($user1, $user2) = (shift, shift);
    my $map = \@_;

    my $chack_game_loading = sub {

        my  $state = get_game_state($$p_user1);

        reset_server();

        ($$p_user1, $$p_user2) =
            Tester::State::register_two_users_and_create_square_map(@$map);
        my $res;
        json_compare_test(
           '{"action": "loadGame", "sid": "' .$$p_user1->{_sid} .'",' .
           '"gameName": "COOLGame",' .
           '"gameState":' . to_json($state) .
           '}', '{"result": "ok"}',
           {res_hook => sub { $res = $_[0] }});

        my $ok = defined $res->{result} && $res->{result} eq 'ok';
        write_msg("\n*** Load Game  ***: $ok\n");
        write_msg(Dumper $res) unless $ok;

        my $new_state = get_game_state($$p_user1);

        $ok = Compare($state, $new_state);
        ok( $ok , 'Restore state' );
        unless ($ok) {
            write_msg("\n*** Restore state  ***: $ok\n");

            open my $f1, '>>', 'f1.txt';
            open my $f2, '>>', 'f2.txt';

    #        print $f1 ($state);
    #        print $f2 ($new_state);

            print $f1 Dumper($state);
            print $f2 Dumper($new_state);

            close $f1;
            close $f2;

            exit();
        }
    };

    ($$p_user1, $$p_user2) = square_map_two_users(@$map);

    before_request( $chack_game_loading );

}

1;
