package Game::Race::Orcs;
use Moose;

use Game::Environment qw(early_response_json global_user global_game);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'orcs' }

sub tokens_cnt { 5 }

override 'compute_coins' => sub {
    super() + @{global_game()->history()}
};

1
