use warnings;
use strict;

use Game::AI;

sub run {
    my $ai = Game::AI::Random->new();

    #$ai->find_and_join_game();
    @{$ai->{data}}{'gameId', 'id', 'sid'} = (1, 3, 3);
    $ai->play();
}

run();
