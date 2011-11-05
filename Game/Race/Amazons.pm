package Game::Race::Amazons;
use Moose;

use Game::Environment qw(early_response_json global_user global_game);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'amazons' }

sub tokens_cnt { 6 }

override 'conquer' => sub {
    if (@{global_game()->history()}) {
        return super()
    }
    global_user()->tokensInHand(global_user()->tokensInHand() + 4);
    super()
};

override 'redeploy' => sub {
    global_user()->tokensInHand(global_user()->tokensInHand() - 4);
    super()
};


1
