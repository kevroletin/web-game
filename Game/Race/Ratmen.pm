package Game::Race::Ratmen;
use Moose;

use Game::Environment qw(:std :response);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'ratmen' }

sub tokens_cnt { 8 }


1
