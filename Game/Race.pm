package Game::Race;
use Moose;

use Game::Environment qw(early_response_json
                         global_user
                         global_game);

# TODO:
#requires 'tokens_cnt';
sub tokens_cnt { 10 }


sub _check_land_type {
    my ($self, $reg) = @_;
    if ('sea' ~~ $reg->landDescription()) {
        early_response_json({result => 'badRegion'})
    }
}

sub _check_land_ownership {
    my ($self, $reg) = @_;
    if ($reg->owner() && !$reg->inDecline() &&
        $reg->owner() eq global_user())
    {
        early_response_json({result => 'badRegion'})
    }
}

sub _check_land_immune {
    my ($self, $reg) = @_;
    for ('dragon', 'hero', 'hole') {
        if ($_ ~~ $reg->extraItems()) {
            early_response_json({result => 'regionIsImmune'});
        }
    }
}

sub _check_land_reachability {
    my ($self, $reg) = @_;
    my $canMove = 0;
    my $map = global_game()->map();
    for (@{$reg->adjacent()}) {
        my $owner = $map->regions()->[$_]->owner();
        $canMove ||= $owner && $owner eq global_user();
        last if $canMove;
    }
    if (!$canMove && !global_user()->have_owned_regions()) {
        for (@{$reg->landDescription()}) {
            $canMove ||=  $_ ~~ ['border', 'coast']
        }
    }
    unless ($canMove) {
        early_response_json({result => 'badRegion'});
    }
}

sub check_is_move_possible {
    my ($self, $reg) = @_;
    $self->_check_land_type($reg);
    $self->_check_land_ownership($reg);
    $self->_check_land_immune($reg);
    $self->_check_land_reachability($reg);
}

sub _calculate_land_strength { 2 }

sub _calculate_fortification_strength {
    my ($self, $reg) = @_;
    my $units_cnt = 0;
    for ('fortifield', 'encampment') {
        if (defined $reg->extraItems()->{$_}) {
            $units_cnt += $reg->extraItems()->{$_}
        }
    }
    $units_cnt
}

sub _kill_defender_units {
    my ($self, $reg, $units_cnt) = @_;
    $reg->owner()->{tokensInHand} += $units_cnt - 1;
}

sub conquer {
    my ($self, $reg) = @_;
    my $game = global_game();
    my $units_cnt = $self->_calculate_land_strength($reg) +
                    $self->_calculate_fortification_strength($reg);

    if (global_user()->tokensInHand() < $units_cnt) {
        early_response_json({result => 'noEnouthUnits'});
    }

    my $defender = $reg->owner();
    if ($defender) {
        $self->_kill_defender_units($reg, $units_cnt);
        $game->state('defend');
    }
    $game->lastAttack({ whom => $reg->owner(),
                        region => $reg });

    # TODO: throw dice

    global_user()->tokensInHand(global_user()->tokensInHand - $units_cnt);

    $reg->owner(global_user());
    $reg->tokensNum($units_cnt);
    #TODO: store history of all attacks

    $defender
}

sub compute_tokens {
    my ($self, $reg) = @_;
    scalar @$reg;
}

1

__END__

=pod

=head1 Races to implement:

amazons
dwarves
elves
giants
halflings
humans
orcs
ratmen
skeletons
sorcerers
tritons
trolls
wizards

=cut

