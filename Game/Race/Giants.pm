package Game::Race::Giants;
use Moose;

use Game::Environment qw(:std :response);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'giants' }

sub tokens_cnt { 6 }

override '_calculate_land_strength' => sub {
    my ($self, $reg) = @_;
    my $was = super();
    for my $reg_num (@{$reg->adjacent()}) {
        my $a_reg = global_game()->map()->get_region($reg_num);
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
