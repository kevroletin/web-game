package Game::Power::Pillaging;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'pillaging' }

sub _power_tokens_cnt { 5 }

override 'compute_coins' => sub {
    my ($self, $regs, $stat) = @_;
    my $conquired = grep { $_->{tokensNum} } @{global_game()->history()};
    $stat->{power} = $conquired unless $self->inDecline();
    super() + $conquired
};


1
