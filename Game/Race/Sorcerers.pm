package Game::Race::Sorcerers;
use Moose;
use JSON;

use Game::Environment qw(assert db early_response_json global_user global_game);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


has 'enchanted' => ( isa => 'Bool',
                     is => 'rw',
                     default => 0 );

sub race_name { 'sorcerers' }

sub tokens_cnt { 5 }

sub __clear_game_state_storage {
    delete global_game()->raceStateStorage()->{enchanted}
}

sub __write_game_state_storage {
    global_game()->raceStateStorage()->{enchanted} = JSON::true;
}

sub enchant {
    my ($self, $reg) = @_;
    if ($self->enchanted()) {
        early_response_json({result => 'badStage'})
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
    $self->__write_game_state_storage();
    db()->update($self, $reg)
}

after 'redeploy' => sub {
    my ($self) = @_;
    $self->enchanted(0);
    $self->__clear_game_state_storage();
    db()->update($self)
};

1
