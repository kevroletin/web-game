package Game::Power::Wealthy;
use Moose::Role;

use Game::Environment qw(:std :db :response);

with( 'Game::Roles::Power' );


has 'firstTurnFinished' => ( isa => 'Bool',
                             is => 'rw',
                             default => 0 );

sub power_name { 'wealthy' }

sub _power_tokens_cnt { 4 }

override 'compute_coins' => sub {
    my ($self, $regs, $stat) = @_;
    return super() if $self->firstTurnFinished();
    $self->firstTurnFinished(1);
    db()->update($self);
    $stat->{power} = 7;
    super() + 7
};



1
