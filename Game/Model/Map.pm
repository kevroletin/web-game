package Game::Model::Map;
use Moose;

use Game::Environment qw(assert compability early_response_json inc_counter);
use Game::Model::Region;
use Moose::Util::TypeConstraints;


our @db_index = qw(mapName mapId);


subtype 'MapName',
    as 'Str',
    where {
        0 < length($_) && length($_) < 16
    },
    message {
        early_response_json({result => 'badMapName'})
    };

subtype 'PlayersNum',
    as 'Int',
    where {
        1 < $_ && $_ <= 5
    },
    message {
        early_response_json({result => 'badPlayersNum'})
    };

subtype 'TurnsNum',
    as 'Str',
    where {
        5 <= $_ && $_ <= 10;
    },
    message {
        early_response_json({result => 'badTurnsNum'})
    };


has 'mapName' => ( isa => 'MapName',
                   is  => 'rw',
                   required => 1 );

has 'playersNum' => ( isa => 'PlayersNum',
                      is  => 'ro',
                      required => 1 );

has 'turnsNum' => ( isa => 'TurnsNum',
                    is => 'ro',
                    required => 1 );

has 'regions' => ( isa => 'ArrayRef[Game::Model::Region]|Undef',
                   is => 'rw',
                   required => 0 );

# FIXME: rename to mapId
sub mapId { $_[0]->id() }
has 'id' => ( isa => 'Int',
              is => 'ro',
              required => 0 );

sub BUILD {
    my ($self) = @_;

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

sub get_region {
    my ($s, $i) = @_;
    $s->regions()->[$i - 1]
}

sub region_by_id {
    my ($self, $id) = @_;
    my $region = undef;
    my $ok = find_type_constraint('Int')->check($id);
    $region = $self->get_region($id) if $ok;
    early_response_json({result => 'badRegionId'}) unless $region;
    $region;
}

1
