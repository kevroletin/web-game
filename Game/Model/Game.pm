package Game::Model::Game;
use Moose;

use Game::Environment qw(early_response_json inc_counter);
use Game::Model::Map;
use Game::Model::User;
use KiokuDB::Set;
use Moose::Util::TypeConstraints;
use KiokuDB::Util qw(weak_set);

our @db_index = qw(gameName gameId);


# TODO: use full type names since types are global objects
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

has 'players' => ( isa => 'ArrayRef[Game::Model::User]',
                   is => 'rw',
                   default => sub { [] } );

has 'activePlayerNum' => ( isa => 'Int',
                           is => 'rw',
                           default => 0 );

has 'lastAttack' => ( isa => 'HashRef|Undef',
                      is => 'rw' );

has 'gameId' => ( isa => 'Int',
                  is => 'ro',
                  required => 0 );

has 'state' => ( isa => 'Str',
                 is => 'rw',
                 default => 'waitingTheBeginning' );

sub BUILD {
    my ($self) = @_;
    $self->{gameId} = inc_counter('Game::Model::Game::gameId');
}

sub activePlayer {
    my ($self) = @_;
    $self->players()->[$self->activePlayerNum()]
}

sub add_player {
    my ($self, $user) = @_;
    push @{$self->players()}, $user
}

sub remove_player {
    my ($self, $user) = @_;
    my $nu = [ grep { ref($_) ne ref($user) } @{$self->players()} ];
    $self->players($nu);
}

sub next_player {
    my ($self) = @_;
    my $n = ($self->activePlayerNum + 1) % @{$self->players()};
    $self->activePlayerNum($n)
}

sub ready {
    my ($self) = @_;
    for my $user (@{$self->players()}) {
        return 0 unless $user->readinessStatus()
    }
    1 && @{$self->players()}
}


1
