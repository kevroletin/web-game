package Game::Power::Heroic;
use Moose::Role;

use Game::Environment qw(:std :response);

with( 'Game::Roles::Power' );


sub power_name { 'heroic' }

sub _power_tokens_cnt { 5 }

after '_redeploy_units' => sub {
    my ($self, $moves) = @_;
    return unless $moves->{heroes_regs};
    for my $reg (@{$moves->{heroes_regs}}) {
        unless ($reg->owner() &&
                $reg->owner() eq global_user())
        {
            early_response_json({result => 'badRegion'})
        }
        my $ei = $reg->extraItems();
        $ei->{hero} = 1 ;
        $reg->extraItems($ei)
    }
};

sub __remove_hero {
    my ($self, $reg) = @_;
    delete $reg->extraItems()->{hero}
};

after '_clear_left_region' => \&__remove_hero;

after '_clear_region_before_redeploy' => \&__remove_hero;

after '_clear_declined_region' => \&__remove_hero;

1
