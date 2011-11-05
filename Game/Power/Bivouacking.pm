package Game::Power::Bivouacking;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


has 'encampmentCnt' => ( isa => 'Int',
                         is => 'rw',
                         default => 5 );

sub power_name { 'bivouaсking' }

sub _power_tokens_cnt { 5 }



1
