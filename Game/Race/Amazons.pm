package Game::Race::Amazons;
use Moose;

use Game::Environment qw(:std :response);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'amazons' }

sub tokens_cnt { 6 }

sub before_first_attack_hook {
    global_user()->tokensInHand( global_user()->tokensInHand() + 4 );
}

before 'redeploy' => sub {
    global_user()->tokensInHand(global_user()->tokensInHand() - 4);
};

1
