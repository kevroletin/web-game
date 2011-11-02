package Tester::State;

use strict;
use warnings;

use Test::More;

use JSON;

use lib '..';
use Tester;
#use Tester::OK;
use Tester::Hooks;


my ($descr, $in, $out, $hooks) = (('') x 4);

my $ok = 1;
my $fail_test;

sub OK {
    $ok &&= $_[0]->{res};
    $fail_test =  $_[1] unless $ok;
#    write_msg("\n*** $_[1]  ***:  ", $_[0]->{quick} . "\n");
#    write_msg($_[0]->{long} . "\n") if $_[0]->{long};
}

sub FINISH {
    my $descr = $fail_test;
    $descr = "Create 2x2 map with 2 users" unless $descr;
    ok($ok, $descr)
#    write_msg("\n*** $_[1]  ***:  ", $_[0]->{quick} . "\n");
#    write_msg($_[0]->{long} . "\n") if $_[0]->{long};
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


sub square_map_two_users {
    my ($d_1, $d_2, $d_3, $d_4, $c1, $c2, $c3, $c4) = @_;
    $$_ ||= 0 for \$c1, \$c2, \$c3, \$c4;

    my $user1 = params_same('sid', 'gameId', 'mapId', 'coins');
    my $user2 = params_same('sid', 'gameId', 'coins');

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
          adjacent => [ 1, 2 ],
          landDescription => [ @$d_1 ],
          population => $c1
        },
        {
          adjacent => [ 0, 3 ],
          landDescription => [ @$d_2 ],
          population => $c2
        },
        {
          adjacent => [ 0, 3 ],
          landDescription => [ @$d_3 ],
          population => $c3
        },
        {
          adjacent => [ 1, 2 ],
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
    "sid": ""
    }'
    , $user1 );


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
    "sid": ""
    }'
    , $user2 );


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

    FINISH();

    ($user1, $user2)
}

1;
