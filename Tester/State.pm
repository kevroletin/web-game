package Tester::State;

use strict;
#use warnings;

use Test::More;

use JSON;
use Data::Compare;
use Data::Dumper::Concise;

use lib '..';
use Game::Constants;
use Tester::New;
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

sub square_map_two_users_debug_state {
  square_map_two_users(@_)
}

=begin comment

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

=cut comment

1;
