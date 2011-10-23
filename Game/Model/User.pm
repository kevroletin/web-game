package Game::Model::User;
use Moose;

use Game::Environment qw(early_response_json);
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

# TODO:
has 'activeRace' => ( isa => 'Str', is => 'rw' );

has 'activePower' => ( isa => 'Str', is => 'rw' );

has 'declineRace' => ( isa => 'Str', is => 'rw' );

has 'declinePower' => ( isa => 'Str', is => 'rw' );


before 'activeGame' => sub {
    my ($self) = @_;
    $self->readinessStatus(0);
};

sub have_owned_regions {
    my ($self) = @_;
    return 0 unless $self->activeGame();
    for (@{$self->activeGame()->map()->regions()}) {
        return 1 if $_->owner() && $_->owner() eq $self
    }
    0
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

