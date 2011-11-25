package Game::Model::User;
use Moose;

use Game::Environment qw(early_response_json inc_counter);
use Game::Model::Game;
use Moose::Util::TypeConstraints;

our @db_index = qw(sid username password);


subtype 'Username',
    as 'Str',
    where {
        /^[A-Za-z][A-Za-z0-9\_\-]{2,15}$/
    },
    message {
        early_response_json({result => 'badUsername'})
    };

subtype 'Password',
    as 'Str',
    where {
        /^.{6,18}$/
    },
    message {
        early_response_json({result => 'badPassword'})
    };

subtype 'ReadinessStatus',
    as 'Int',
    where {
        $_ == 0 || $_ == 1
    },
    message {
        early_response_json({result => 'badReadinessStatus'})
    };


has 'sid' => ( isa => 'Str',
               is  => 'rw',
               required => 0 );

has 'username' => ( isa => 'Username',
                is  => 'rw',
                required => 1 );

has 'password' => ( isa => 'Password',
                    is  => 'rw',
                    required => 1 );

has 'activeGame' => ( isa => 'Game::Model::Game|Undef',
                      is => 'rw' );

has 'readinessStatus' => ( isa => 'ReadinessStatus',
                           is => 'rw',
                           default => 0 );

has 'tokensInHand' => ( isa => 'Int',
                        is => 'rw',
                        default => 0 );

has 'coins' => ( isa => 'Int',
                 is => 'rw',
                 default => 0 );

has 'id' => ( isa => 'Int',
              is => 'ro',
              required => 0 );

has 'activeRace' => ( isa => 'Game::Race|Undef',
                      is => 'rw' );

has 'declineRace' => ( isa => 'Game::Race|Undef',
                       is => 'rw' );

sub BUILD {
    my ($self) = @_;
    $self->{id} = inc_counter('Game::Model::User::id');
}

before 'activeGame' => sub {
    my ($self) = shift;
    if (@_) {
        $self->readinessStatus(0);
        $self->coins(5);
    }
};

sub extract_state {
    my ($self) = @_;
    return undef unless $self->activeGame();
    my $res = {};
    if ($self->activeGame()->state() eq 'notStarted') {
        $res->{readinessStatus} = $self->readinessStatus()
    }
    $res->{tokensInHand} = $self->tokensInHand();
    $res->{coins} = $self->coins();
    $res->{id} = $self->id();
    if ($self->activeRace()) {
        $res->{activeRace} =  $self->activeRace()->race_name();
        $res->{activePower} =  $self->activeRace()->power_name();
        my $st = $self->activeRace()->extract_state();
        $res->{activeState} = $st if $st
    }
    if ($self->declineRace()) {
        $res->{declineRace} = $self->declineRace()->race_name();
        $res->{declinePower} = $self->declineRace()->power_name();
        my $st = $self->declineRace()->extract_state();
        $res->{declineState} = $st if $st
    }
    $res
}

sub have_owned_regions {
    my ($self) = @_;
    return 0 unless $self->activeGame();
    for (@{$self->activeGame()->map()->regions()}) {
        return 1 if $_->owner() && $_->owner() eq $self
    }
    0
}

sub number_in_game {
}

sub owned_regions {
    my ($self) = @_;
    return undef unless $self->activeGame();
    grep { $_->owner() && $_->owner() eq $self
          } @{$self->activeGame()->map()->regions()}
}

sub short_info {
    my ($s) = @_;
    unless ($s->activeGame()) {
        return { username => $s->username,
                 id => $s->id }
    }
    my $res = {
        username => $s->username,
        id => $s->id,
        activeGameId => $s->activeGame->activeGame()->gameId(),
        activeGameName => $s->activeGame->activeGame()->gameName(),
        readinessStatus => $s->readinessStatus(),
        tokensInHand => $s->tokensInHand(),
        coins => $s->coins(),
        activeRace => $s->activeRace()->race_name(),
        activePower => $s->activeRace()->power_name(),
        declineRace => $s->declineRace()->race_name(),
        declinePower => $s->declineRace()->power_name()
    };
    $res
}


1

__END__

=head1 NAME

Model::User - описание модели User

=head1 DETAILS

Смотрите L<Moose> для подробностей.

=cut

