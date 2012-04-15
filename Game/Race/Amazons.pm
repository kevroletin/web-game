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

#override 'conquer' => sub {
#    return super() if feature('amazons_remove_tokens_after_redeploy');

#    if (@{global_game()->history()}) {
#        return super()
#    }
#    global_user()->tokensInHand(global_user()->tokensInHand() + 4);
#    super()
#};

override 'redeploy' => sub {
    return super() if feature('amazons_remove_tokens_after_redeploy');

    global_user()->tokensInHand(global_user()->tokensInHand() - 4);
    super()
};

after 'redeploy' => sub {
    return super() unless feature('amazons_remove_tokens_after_redeploy');

    my $rest = global_user()->tokensInHand() - 4;
    if ($rest < 0) {
        global_user()->tokensInHand(0);
        for my $reg (global_user()->owned_active_regions()) {
            while ($rest < 0 && $reg->population()) {
                $reg->population( $reg->population() - 1 );
                ++$rest;
            }
        }
    }
};

1
