package Game::Race::Skeletons;
use Moose;

use Game::Environment qw(early_response_json global_user global_game);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'skeletons' }

sub tokens_cnt { 6 }

before 'redeploy' => sub {
    my ($self) = @_;
    my $conquired = grep { $_->{tokensNum} } @{global_game()->history()};
    my $new_cnt = global_user()->tokensInHand() + int($conquired/2);
    global_user()->tokensInHand($new_cnt);
};


1
