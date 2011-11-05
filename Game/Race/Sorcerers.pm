package Game::Race::Sorcerers;
use Moose;

use Game::Environment qw(db early_response_json global_user global_game);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


has 'enchanted' => ( isa => 'Bool',
                     is => 'rw',
                     default => 0 );

sub race_name { 'sorcerers' }

sub tokens_cnt { 5 }

sub extract_state {
    my ($self) = @_;
    my $res = {};
    # TODO: try to make unblessed copy or use introspection
    # to determine object fields
    $res->{enchanted} = $self->{enchanted};
    $res
}

sub load_state { } # TODO:

sub enchant {
    my ($self, $reg) = @_;
    if ($self->enchanted()) {
        early_response_json({result => 'badGameStage'})
    }
    unless ($self->_region_is_adjacent_with_our($reg) &&
            !$reg->inDecline() &&
            $reg->owner() && $reg->owner() ne global_user() &&
            $reg->tokensNum() == 1)
    {
        early_response_json({result => 'badRegion'})
    }
    $self->_check_land_immune($reg);

    global_game()->add_to_attack_history($reg);
    $reg->owner_race()->_clear_left_region($reg);
    $reg->owner(global_user());

    $self->enchanted(1);
    db()->update($self, $reg)
}

after 'redeploy' => sub {
    my ($self) = @_;
    $self->enchanted(0);
    db()->update($self)
};

1
