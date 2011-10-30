package Game::Model::Game;
use Moose;

use Game::Constants;
use Game::Environment qw(early_response_json inc_counter);
use Game::Model::Map;
use Game::Model::User;
use KiokuDB::Set;
use Moose::Util::TypeConstraints;
use KiokuDB::Util q(weak_set);
use List::Util q(shuffle);

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
#{ whom => Game::Model::User,
#  region => Game::Model::Region }

has 'gameId' => ( isa => 'Int',
                  is => 'ro',
                  required => 0 );

has 'state' => ( isa => 'Str',
                 is => 'rw',
                 default => 'notStarted' );

has 'racesPack' => ( isa => 'ArrayRef[Str]',
                     is => 'rw',
                     default => sub { [] } );

has 'powersPack' => ( isa => 'ArrayRef[Str]',
                      is => 'rw',
                      default => sub { [] } );

has 'bonusMoney' => ( isa => 'ArrayRef[Int]',
                      is => 'rw',
                      default => sub { [(0) x 6] } );

# TODO:
# has 'history' => ...

sub BUILD {
    my ($self) = @_;
    $self->{gameId} = inc_counter('Game::Model::Game::gameId');
}

before 'state' => sub {
    my ($self, $new_state) = @_;
    use Data::Dumper;
    if (defined $new_state &&
        $self->state() eq 'notStarted' &&
        $new_state eq 'startMoving')
    {
        $self->_create_tokens_pack();
    }
};

sub activePlayer {
    my ($self) = @_;
    $self->players()->[$self->activePlayerNum()]
}

sub add_player {
    my ($self, $user) = @_;
    push @{$self->players()}, $user
}

sub _create_tokens_pack {
    my ($self) = @_;
    $self->racesPack([shuffle @Game::Constants::races]);
    $self->powersPack([shuffle @Game::Constants::powers]);
}

sub _extract_last_attack {
    my ($self) = @_;
    my $la = $self->lastAttack();
    return undef unless $la;
    { #whom => $self->number_of_user($la->{whom}),
      whom => $la->{whom} ? $la->{whom}->id() : undef,
      reg => $self->number_of_region($la->{region}) }
}

sub _extract_visible_tokens {
    my ($self) = @_;
    my @res;
    for my $i (0 .. 5) {
        my $tok = {};
        $tok->{raceName} = $self->racesPack()->[$i];
        $tok->{specialPowerName} = $self->powersPack()->[$i];
        $tok->{position} = $i;
        $tok->{bonusMoney} = $self->bonusMoney()->[$i];
        push @res, $tok
    }
    \@res
}

sub extract_state {
    my ($self) = @_;
    my $res = {};
    $res->{activePlayerNum} = $self->activePlayerNum();
    $res->{lastAttack} = $self->_extract_last_attack();
    $res->{state} = $self->state();
    my @players_st;
    push @players_st, $_->extract_state() for @{$self->players()};
    $res->{players} = \@players_st;
    my @regions;
    push @regions, $_->extract_state() for @{$self->map()->regions()};
    $res->{regions} = \@regions;
    $res->{visibleTokenBadges} = $self->_extract_visible_tokens();
    $res
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

sub number_of_user {
    my ($self, $user) = @_;
    return undef unless $user;
    my $i = 0;
    for (@{$self->players()}) {
        return $i if $_ eq $user;
        ++$i
    }
    undef
}

sub number_of_region {
    my ($self, $region) = @_;
    return undef unless $region;
    my $i = 0;
    for (@{$self->map()->regions()}) {
        return $i if $_ eq $region;
        ++$i
    }
    undef
}

sub ready {
    my ($self) = @_;
    for my $user (@{$self->players()}) {
        return 0 unless $user->readinessStatus()
    }
    1 && @{$self->players()}
}

sub pick_tokens {
    my ($self, $race_num) = @_;
    my $race = splice @{$self->racesPack()}, $race_num, 1;
    my $power = splice @{$self->powersPack()}, $race_num, 1;
    my $coins = splice @{$self->bonusMoney()}, $race_num, 1;
    push @{$self->bonusMoney()}, 0;
    ($race, $power, $coins)
}

sub put_back_tokens {
    my ($self, $race) = @_;
    push @{$self->racesPack()}, $race->race_name();
    push @{$self->powersPack()}, $race->power_name();
}

1
