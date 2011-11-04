package Game::Race::Giants;
use Moose;

use Game::Environment qw(early_response_json global_user global_game);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'giants' }

sub tokens_cnt { 6 }

override '_calculate_land_strength' => sub {
    my ($self, $reg) = @_;
    my $was = super();
    for my $reg_num (@{$reg->adjacent()}) {
        my $a_reg = global_game()->map()->regions()->[$reg_num];
        if ('mountain' ~~ $a_reg->landDescription() &&
            $a_reg->owner() &&
            $a_reg->owner() eq global_user())
        {
            return $was - 1
        }
    }
    $was
};


1
