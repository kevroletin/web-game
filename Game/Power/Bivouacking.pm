package Game::Power::Bivouacking;
use Moose::Role;

use Game::Environment qw(:std :response);
use List::Util qw( sum );

with( 'Game::Roles::Power' );


sub power_name { 'bivouacking' }

sub _power_tokens_cnt { 5 }

after '_redeploy_units' => sub {
    my ($self, $moves) = @_;
    my $enc_cnt = sum 0, grep { $_ }
        map { $_->extraItems()->{encampment} }
            global_user()->owned_regions();
    $enc_cnt += $moves->{encampments_sum} || 0;
    if ($enc_cnt > 5) {
        early_response_json({result => 'badEncampmentsNum'})
    }
    for (@{$moves->{encampments}}) {
        my ($reg, $cnt) = @{$_};
        unless ($reg->owner() &&
                $reg->owner() eq global_user())
        {
            early_response_json({result => 'badRegion'})
        }
        my $ei = $reg->extraItems();
        $ei->{encampment} ||= 0;
        $ei->{encampment} += $cnt;
        $reg->extraItems($ei)
    }
};

sub __remove_encampment {
    my ($self, $reg) = @_;
    delete $reg->extraItems()->{encampment}
};

after 'clear_reg_and_die' => \&__remove_encampment;

after '_clear_left_region' => \&__remove_encampment;

after '_clear_region_before_redeploy' => \&__remove_encampment;

after '_clear_declined_region' => \&__remove_encampment;


1
