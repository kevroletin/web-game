package Game::Race::Debug;
use Moose;

use Game::Environment qw(:std :response);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'debug' }

sub tokens_cnt { 0 }

1
