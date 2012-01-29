package Game::Power::Alchemist;
use Moose::Role;

use Game::Environment qw(:std :response);

with( 'Game::Roles::Power' );


sub power_name { 'alchemist' }

sub _power_tokens_cnt { 4 }

override 'compute_coins' => sub {
    my ($self, $regs, $stat) = @_;
    $stat->{power} = 2 unless $self->inDecline();
    $self->inDecline() ? super() : super() + 2
};


1
