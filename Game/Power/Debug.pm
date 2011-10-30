package Game::Power::Debug;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'dummy' }

#around 'tokens_cnt' => sub {
#    my ($orig, $self) = @_;
#    $self->$orig() + 5
#};


1
