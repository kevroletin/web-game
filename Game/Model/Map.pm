package Game::Model::Map;
use Moose;

use Game::Environment qw(compability early_response_json inc_counter);
use Game::Model::Region;
use Moose::Util::TypeConstraints;


our @db_index = qw(mapName id);


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

has 'id' => ( isa => 'Int',
              is => 'ro',
              required => 0 );

sub BUILD {
    my ($self) = @_;
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
    --$i if compability();
    $s->regions()->[$i]
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
