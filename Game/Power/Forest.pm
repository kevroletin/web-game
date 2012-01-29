package Game::Power::Forest;
use Moose::Role;

use Game::Environment qw(:std :response);

with( 'Game::Roles::Power' );


sub power_name { 'forest' }

sub _power_tokens_cnt { 4 }

override 'compute_coins' => sub {
    my ($self, $regs, $st) = @_;
    return super() if $self->inDecline();
    super() + ($st->{power} = grep { 'forest' ~~ $_->landDescription() } @$regs)
};


1
