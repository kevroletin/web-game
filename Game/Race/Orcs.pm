package Game::Race::Orcs;
use Moose;

use Game::Environment qw(early_response_json global_user global_game);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'orcs' }

sub tokens_cnt { 5 }

before 'redeploy' => sub {
    my ($self) = @_;
    my $extra_units = @{global_game()->history()};
    my $new_cnt = global_user()->tokensInHand() + $extra_units;
    global_user()->tokensInHand($new_cnt);
};

1
