package Game::Power::Swamp;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'swamp' }

sub _power_tokens_cnt { 4 }

override 'compute_coins' => sub {
    my ($self, $regs) = @_;
    return super() if $self->inDecline();
    super() + grep { 'swamp' ~~ $_->landDescription() } @$regs;
};


1
