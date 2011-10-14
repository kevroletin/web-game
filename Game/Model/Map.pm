package Game::Model::Map;
use Moose;

use Game::Environment qw(early_response_json inc_counter);
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

sub region_by_id {
    my ($self, $id) = @_;
    my $c = find_type_constraint('Int');
    $c->validate($id);
    my $region = $self->regions()->[$id];
    $c->get_message() unless $region;
    $region
}

1
