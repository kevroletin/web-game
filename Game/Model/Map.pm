package Game::Model::Map;
use Moose;

use Game::Environment qw(early_response_json);
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
        0 < $_ && $_ <= 5
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

subtype 'Region',
    as 'HashRef',
    where {
        # TODO:
        defined $_->{adjacent} &&
        defined $_->{landDescription} &&
        defined $_->{population}
    },
    message {
        early_response_json({result => 'badRegions'})
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

has 'regions' => ( isa => 'ArrayRef[Region]|Undef',
                   is => 'rw',
                   required => 0 );

has 'id' => ( isa => 'Int',
              is => 'ro',
              required => 1 );

1
