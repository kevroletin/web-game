use warnings;
use strict;

use Game::AI;
use Game::Environment ':config';

use Data::Dumper::Concise;

$SIG{__DIE__} = \&Carp::confess;
$SIG{__WARN__} = \&Carp::confess;

=begin comment

use Devel::StackTrace;
sub _dier {
    my $t = Devel::StackTrace->new(
                indent => 1, message => $_[0],
                ignore_package => [__PACKAGE__, 'Game::Exception']
            );
    stack_trace($t);
    die @_;
}

$SIG{__WARN__} = \&_dier;
$SIG{__DIE__} = \&_dier;
$SIG{INT} = \&_dier;

=cut comment

sub run {
    #my $ai = Game::AI::Random->new();
    #my $ai = Game::AI::Random->new({url => 'http://server.smallworld'});
    my $ai = Game::AI::Random->new({url => 'http://server.lena/small_worlds'});

    if (@ARGV) {
        @{$ai->{data}}{'id', 'sid'} = (@ARGV[0, 1]);
    } else {
        $ai->find_and_join_game();
    }
    $ai->continue_game(1);
#    eval {
        $ai->play();
#    };
    if ($@) {
        print Dumper $@;
        my $str = stack_trace()->as_string();#html();
        utf8::encode($str) if utf8::is_utf8($str);
        print $str;
    }
}

run();
