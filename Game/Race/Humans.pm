package Game::Race::Humans;
use Moose;

use Game::Environment qw(early_response_json global_user global_game);

extends( 'Game::Race' );



sub race_name { 'humans' }


1
