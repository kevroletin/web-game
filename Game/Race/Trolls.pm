package Game::Race::Trolls;
use Moose;

use Game::Environment qw(early_response_json global_user global_game);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'trolls' }

sub tokens_cnt { 5 }

sub extra_defend { 1 }

1
