use warnings;
use strict;

use Game::AI;
use Game::Environment ':config';

use Data::Dumper::Concise;

#$SIG{__DIE__} = \&Carp::confess;
#$SIG{__WARN__} = \&Carp::confess;

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


sub run {
    #    my $ai = Game::AI::Random->new();
    my $ai = Game::AI::Simple->new();

    #$ai->find_and_join_game();
    @{$ai->{data}}{'id', 'sid'} = (2, 2);
    $ai->continue_game(1);
    eval {
        $ai->play();
    };
    if ($@) {
        print Dumper $@;
        my $str = stack_trace()->as_string();#html();
        utf8::encode($str) if utf8::is_utf8($str);
        print $str;
    }
}

run();
