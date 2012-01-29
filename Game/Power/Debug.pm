package Game::Power::Debug;
use Moose::Role;

use Game::Environment qw(:std :response);

with( 'Game::Roles::Power' );


sub power_name { 'debug' }

sub _power_tokens_cnt { 0 }

#around 'tokens_cnt' => sub {
#    my ($orig, $self) = @_;
#    $self->$orig() + 5
#};


1
