package Game::Power::Wealthy;
use Moose::Role;

use Game::Environment qw(db early_response_json global_user
                         global_game);

with( 'Game::Roles::Power' );


has 'firstTurnFinished' => ( isa => 'Bool',
                             is => 'rw',
                             default => 0 );

sub power_name { 'wealthy' }

sub _power_tokens_cnt { 4 }

override 'compute_coins' => sub {
    my ($self) = @_;
    return super() if $self->firstTurnFinished();
    $self->firstTurnFinished(1);
    db()->update($self);
    super() + 7
};



1
