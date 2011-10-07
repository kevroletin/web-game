package Game::Model::Game;
use Moose;

use Game::Environment qw(early_response_json inc_counter);
use Game::Model::Map;
use KiokuDB::Set;
use Moose::Util::TypeConstraints;

our @db_index = qw(gameName gameId);


subtype 'GameName',
    as 'Str',
    where {
        0 < length($_) && length($_) <= 50
    },
    message {
        early_response_json({result => 'badGameName'})
    };

subtype 'playersNum',
    as 'Int',
    where {
        0 < $_ && $_ <= 5
    },
    message {
        early_response_json({result => 'badnumberOfPlayers'})
    };


has 'gameName' => ( isa => 'GameName',
                    is => 'ro',
                    required => 1 );

has 'map' => ( isa => 'Game::Model::Map',
               is => 'rw',
               required => 0 );

has 'gameDescr' => ( isa => 'Str|Undef',
                     is => 'rw' );

has 'players' => ( does => 'KiokuDB::Set',
                   is => 'rw' );

has 'gameId' => ( is => 'Int',
                  is => 'ro',
                  required => 0 );

sub BUILD {
    my ($self) = @_;
    $self->{gameId} = inc_counter('Game::Model::Game::gameId');
}

1
