package Game::Power::Commando;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Power' );


sub power_name { 'commando' }


1
