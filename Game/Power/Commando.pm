package Game::Power::Commando;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'commando' }

sub _power_tokens_cnt { 4 }

override '_calculate_land_strength' => sub {
    super() - 1
};


1
