package Game::Power::Alchemist;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'alchemist' }

sub _power_tokens_cnt { 4 }

override 'compute_coins' => sub {
    my ($self) = @_;
    $self->inDecline() ? super() : super() + 2
};


1
