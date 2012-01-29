package Game::Race::Tritons;
use Moose;

use Game::Environment qw(:std :response);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'tritons' }

sub tokens_cnt { 6 }

override '_calculate_land_strength' => sub {
    my ($self, $reg) = @_;
    my $was = super();
    'coast' ~~ $reg->landDescription() ? $was - 1 : $was
};


1
