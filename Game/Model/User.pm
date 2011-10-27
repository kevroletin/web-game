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

has 'activeRace' => ( isa => 'Game::Race',
                      is => 'rw' );

has 'declineRace' => ( isa => 'Game::Race',
                       is => 'rw' );

sub BUILD {
    my ($self) = @_;
    $self->{id} = inc_counter('Game::Model::User::id');
}

before 'activeGame' => sub {
    my ($self) = shift;
    if (@_) {
        $self->readinessStatus(0);
        $self->coins(0);
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
    if ($self->activeRace()) {
        $res->{activeRace} =  $self->activeRace()->race_name();
        $res->{activePower} =  $self->activeRace()->power_name();
    }
    if ($self->declineRace()) {
        $res->{declineRace} = $self->declineRace()->race_name();
        $res->{declinePower} = $self->declineRace()->power_name();
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
    my ($self) = @_;
    return undef unless $self->activeGame();
    my $i = 0;
    for (@{$self->activeGame()->players()}) {
        return $i if $_ eq $self;
        ++$i
    }
    die "user not in activeGame players set"
}

sub owned_regions {
    my ($self) = @_;
    return undef unless $self->activeGame();
    grep { $_->owner() && $_->owner() eq $self
          } @{$self->activeGame()->map()->regions()}
}


1

__END__

=head1 NAME

Model::User - описание модели User

=head1 DETAILS

Смотрите L<Moose> для подробностей.

=cut

