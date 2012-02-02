package Game::Model::Map;
use Moose;

use Game::Environment qw(:std :db :response);
use Game::Model::Region;
use Moose::Util::TypeConstraints;


our @db_index = qw(mapName id);


subtype 'Game::Model::Map::MapName',
    as 'Str',
    where { 0 < length($_) && length($_) < 16 },
    message { assert(0, 'badMapName') };

subtype 'Game::Model::Map::PlayersNum',
    as 'Int',
    where { 1 < $_ && $_ <= 5 },
    message { assert(0, 'badPlayersNum') };

subtype 'Game::Model::Map::TurnsNum',
    as 'Str',
    where { 5 <= $_ && $_ <= 10; },
    message { assert(0, 'badTurnsNum') };

has 'mapName' => ( isa => 'Game::Model::Map::MapName',
                   is  => 'rw',
                   required => 1 );

has 'playersNum' => ( isa => 'Game::Model::Map::PlayersNum',
                      is  => 'ro',
                      required => 1 );

has 'turnsNum' => ( isa => 'Game::Model::Map::TurnsNum',
                    is => 'ro',
                    required => 1 );

has 'regions' => ( isa => 'ArrayRef[Game::Model::Region]',
                   is => 'rw',
                   required => 1 );

has 'id' => ( isa => 'Maybe[Int]',
              is => 'rw' );

has 'picture' => ( isa => 'Str',
                   is => 'rw',
                   default => '' );


sub BUILD {
    my ($self) = @_;
    for my $i (1 .. @{$self->regions()}) {
        $self->regions()->[$i - 1]->regionId($i)
    }

#    assert(@{$self->regions()} >= 1, 'badRegions', descr => 'notEnouthRegions');

    my $population = 0;
    for my $i (1 .. @{$self->regions()}) {
        my $reg = $self->get_region($i);
        $population += defined $reg->{population} ? $reg->{population} : 0 ;
        my $adj = $reg->{adjacent};
        for (@$adj) {
            assert($_ != $i &&
                   $_ >= 1 &&
                   $_ <= @{$self->regions()},
                   'badRegions', regNum => $i, descr => 'badAdjacent', cause => $_);
            assert($i ~~ $self->get_region($_)->{adjacent}, 'badRegions',
                   regNum => $i, descr => 'inconsistentAdjasent');
        }
    }
    assert($population <= 18, 'badRegions', descr => 'tooManyFreeTokens');

    $self->{id} = inc_counter('Game::Model::Map::id');
}

sub get_region {
    my ($s, $i) = @_;
    $s->regions()->[$i - 1]
}

sub region_by_id {
    my ($self, $id) = @_;
    my $region = undef;
    my $ok = find_type_constraint('Int')->check($id) && $id > 0;
    $region = $self->get_region($id) if $ok;
    assert($region, 'badRegionId');
#    assert($region, 'badRegion', descr => 'badId');
    $region;
}

# --- state ---

sub extract_state_durty {
    my ($s) = @_;
    my $res = $s->short_info();
    $res->{mapId} = $s->id();
    $res->{mapName} = $s->mapName();
    $res->{playersNum} = $s->playersNum();
    $res->{turnsNum} = $s->turnsNum();
    $res->{regions} = [];
    for my $reg (@{$s->regions()}) {
        my $st = {};
        $st->{coordinates} = $reg->coordinates();
        $st->{raceCoords} = $reg->raceCoords();
        $st->{powerCoords} = $reg->powerCoords();
        $st->{constRegionState} = $reg->landDescription;
        $st->{adjacentRegions} = $reg->adjacent();
        $_ = $reg->extraItems();
        $st->{currentRegionState} = {
             ownerId => $reg->owner() ? $reg->owner()->id() : undef,
             tokenBadgeId => $reg->owner_race() ?
                 $reg->owner_race()->tokenBadgeId() : undef,
             dragon => bool($_->{dragon}),
             encampment => num($_->{encampment}),
             fortified => bool($_->{fortified}),
             hero => bool($_->{hero}),
             holeInTheGround => bool($_->{hole}),
             inDecline => bool($reg->inDecline() || !$reg->owner()),
             tokensNum => num($reg->population())
        };

# TODO: DEBUG:
        $st->{regionId} = $reg->{regionId};

        push @{$res->{regions}}, $st
    }
    $res
}

sub extract_state_clear {
    my ($s) = @_;
    [ map { $_->extract_state() } @{$s->regions()} ]
}

sub short_info {
    my ($s) = @_;
    my %h = %{$s};
    $h{regionsNum} = @{$h{regions}};
    $h{mapId} = $h{id}; delete $h{id};
    delete $h{regions};
    \%h;
}

sub full_info {
    my ($s) = @_;
    my $r = $s->short_info();
    $r->{regions} =
        [map { $_->extract_const_descr()} @{$s->regions()}];
    $r
}


__PACKAGE__->meta->make_immutable;
