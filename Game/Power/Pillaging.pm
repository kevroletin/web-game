package Game::Power::Pillaging;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'pillaging' }

sub _power_tokens_cnt { 5 }

override 'compute_coins' => sub {
    my ($self) = @_;
    my $conquired = grep { $_->{tokensNum} } @{global_game()->history()};
    super() + $conquired
};


1
