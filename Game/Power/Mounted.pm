package Game::Power::Mounted;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'mounted' }

sub _power_tokens_cnt { 4 }

override '_calculate_land_strength' => sub {
    my ($self, $reg) = @_;
    if ('hill' ~~ $reg->landDescription() ||
        'farmland' ~~ $reg->landDescription())
    {
        return super() - 1
    }
    super()
};


1
