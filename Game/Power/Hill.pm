package Game::Power::Hill;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'hill' }

sub _power_tokens_cnt { 4 }

override 'compute_coins' => sub {
    my ($self, $regs) = @_;
    return super() if $self->inDecline();
    super() + grep { 'hill' ~~ $_->landDescription() } @$regs;
};



1
