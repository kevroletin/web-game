package Game::Power::Swamp;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'swamp' }

sub _power_tokens_cnt { 4 }

override 'compute_coins' => sub {
    my ($self, $regs, $stat) = @_;
    return super() if $self->inDecline();
    my $bonus = grep { 'swamp' ~~ $_->landDescription() } @$regs;
    $stat->{power} = $bonus unless $self->inDecline();
    super() + $bonus;
};


1
