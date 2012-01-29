package Game::Race::Orcs;
use Moose;

use Game::Environment qw(:std :response);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'orcs' }

sub tokens_cnt { 5 }

override 'compute_coins' => sub {
    super() + ($_[2]->{race} = @{global_game()->history()})
};

1
