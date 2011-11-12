package Game::Power::Merchant;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'merchant' }

sub _power_tokens_cnt { 2 }

override 'compute_coins' => sub {
    my ($self, $regs) = @_;
    super() + @$regs
};



1
