package Game::Power::Flying;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'flying' }

sub _power_tokens_cnt { 5 }

override '_check_land_reachability' => sub { 1 };


1
