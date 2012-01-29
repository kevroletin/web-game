package Game::Race::Dwarves;
use Moose;

use Game::Environment qw(:std :response);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'dwarves' }

sub tokens_cnt { 3 }

override 'compute_coins' => sub {
    my ($self, $regs, $st) = @_;
    super() + ($st->{race} = int grep { 'mine' ~~ $_->landDescription() } @$regs);
};

1
