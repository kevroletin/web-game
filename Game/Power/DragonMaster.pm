package Game::Power::DragonMaster;
use Moose::Role;

use Game::Environment qw(:std :db :response);

with( 'Game::Roles::Power' );

has 'dragonUsed' => ( isa => 'Bool',
                      is => 'rw',
                      default => 0 );

sub power_name { 'dragonMaster' }

sub _power_tokens_cnt { 5 }

after 'redeploy' => sub {
    my ($self) = @_;
    $self->dragonUsed(0);
    db()->update($self)
};

sub dragonAttack {
    my ($self, $reg) = @_;
    if ($self->dragonUsed()) {
        early_response_json({result => 'badStage'})
    }
    if (global_user()->tokensInHand() < 1) {
        early_response_json({result => 'noEnouthUnits'})
    }
    $self->_check_land_immune($reg);
    if ($reg->owner() && $reg->owner() eq global_user()) {
        early_response_json({result => 'badRegion'})
    }

    $self->dragonUsed(1);
    my $defender = $self->__kill_region_owner($reg);
    global_user()->tokensInHand(global_user()->tokensInHand - 1);
    $reg->owner(global_user());
    $reg->tokensNum(1);
    $reg->inDecline(0);
    my $ei = $reg->extraItems();
    $ei->{dragon} = 1;
    $reg->extraItems($ei);

    db()->update(grep { $_ } $self, global_game(), $reg,
                 $defender, global_user());
}

sub __remove_dragon {
    my ($self, $reg) = @_;
    delete $reg->extraItems()->{dragon}
}

after 'inDecline' => sub {
    my ($self, $val) = @_;
    if ($val && $val == 1) {
        for (global_user()->owned_regions()) {
            # don't need db()->update since all user regions will
            # be saved after changing inDecline value
            $self->__remove_dragon($_)
        }
    }
};

after '_clear_left_region' => \&__remove_dragon;

after '_clear_declined_region' => \&__remove_dragon;

after '_clear_region_before_redeploy' => \&__remove_dragon;


1
