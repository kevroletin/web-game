package Game::Power::Underworld;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);

with( 'Game::Roles::Power' );


sub power_name { 'underworld' }

sub _power_tokens_cnt { 5 }

override '_calculate_land_strength' => sub {
    my ($self, $reg) = @_;
    if ('cavern' ~~ $reg->landDescription()) {
        return super() - 1
    }
    super()
};

override '_region_is_adjacent_with_our' => sub {
    my ($self, $reg) = @_;
    my $super = super();
    if ($super || !('cavern' ~~ $reg->landDescription())) {
        return $super
    }
    for (global_user()->owned_regions()) {
        return 1 if 'cavern' ~~ $_->landDescription()
    }
    return 0
};

1
