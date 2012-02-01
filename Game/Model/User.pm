package Game::Model::User;
use Moose;

#use Digest::SHA1 ();

use Game::Constants qw(races_with_debug powers_with_debug);
use Game::Environment qw(:std :db :response);
use Game::Model::Game;
use Moose::Util::TypeConstraints;
use Moose::Util qw( apply_all_roles );
use JSON;

our @db_index = qw(id sid username password);


subtype 'Game::Model::User::Username',
    as 'Str',
    where { /^[A-Za-z_][A-Za-z0-9\_\-\.]{2,15}$/ },
    message { assert(0, 'badUsername') };

subtype 'Game::Model::User::Password',
    as 'Str',
    where { /^.{6,18}$/},
    message { assert(0, 'badPassword') };

subtype 'Game::Model::User::ReadinessStatus',
    as 'Int',
    where { $_ == 0 || $_ == 1 },
    message { assert(0, 'badReadinessStatus') };

has isAi => ( is => 'Bool',
              is => 'rw',
              default => 0 );

has 'sid' => ( isa => 'Str',
               is  => 'rw',
               required => 0 );

has 'username' => ( isa => 'Game::Model::User::Username',
                    is  => 'rw',
                    required => 1 );

has 'password' => ( isa => 'Game::Model::User::Password',
                    is  => 'rw',
                    required => 1 );

has 'activeGame' => ( isa => 'Game::Model::Game|Undef',
                      is => 'rw' );

has 'readinessStatus' => ( isa => 'Game::Model::User::ReadinessStatus',
                           is => 'rw',
                           default => 0 );

has 'tokensInHand' => ( isa => 'Int',
                        is => 'rw',
                        default => 0 );

has 'coins' => ( isa => 'Int',
                 is => 'rw',
                 default => 0 );

sub userId { $_[0]->id() }
has 'id' => ( isa => 'Int',
              is => 'ro',
              required => 0 );

has 'activeRace' => ( isa => 'Game::Race|Undef',
                      is => 'rw' );

has 'declineRace' => ( isa => 'Game::Race|Undef',
                       is => 'rw' );

# TODO: move into Game::Model::Game
has 'raceSelected' => ( isa => 'Bool',
                        is => 'rw',
                        default => 0 );

sub BUILD {
    my ($self) = @_;
    unless ($self->isAi()) {
        my $ok = $self->{username} =~ /^[A-Za-z][A-Za-z0-9\-]{2,15}$/;
        assert($ok, 'badUsername');
    }
    $self->{id} = inc_counter('Game::Model::User::id');
}

before 'activeGame' => sub {
    my $self = shift;
    if (@_) {
        $self->readinessStatus(0);
        $self->coins(5);
    }
};

sub generate_sid {
    my ($self) = @_;

    if (is_debug()) {
        $self->sid( inc_counter('Game::Model::User::sid') );
        return
    }

    my $sid;
    while (1) {
        $sid = Digest::SHA1::sha1_hex(rand() . time() .
                                      'secret#$#%#%#%#%@#KJDFSd24');
        last unless (db_search({ sid => $sid })->all());
    }
    $self->sid( $sid )
}

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

# --- state ---

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

sub load_state {
    my ($s, $d) = @_;
    $d->{readinessStatus} = 1 unless $d->{readinessStatus};

    my $create_pair = sub {
        my ($race, $power, $state) = @_;
        return undef if !defined $race && !defined $power;
        assert((defined $race && defined $power),
               'incompletePair',
               race => $race, power => $power);
        assert(($race ~~ races_with_debug()), 'badRace',
               race => $race);
        assert(($power ~~ powers_with_debug()), 'badPower',
               power => $power);

        $race = "Game::Race::" . ucfirst($race);
        $power = "Game::Power::" . ucfirst($power);
        my $pair = $race->new();
        apply_all_roles($pair, $power);
        $pair->load_state($state, $s);
        $pair
    };

    $s->readinessStatus($d->{readinessStatus});
    $s->tokensInHand($d->{tokensInHand});
    $s->coins($d->{coins});
    $s->activeRace( $create_pair->($d->{activeRace},
                                   $d->{activePower},
                                   $d->{activeState}) );
    $s->declineRace( $create_pair->($d->{declineRace},
                                    $d->{declinePower},
                                    $d->{declineState}) );
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


__PACKAGE__->meta->make_immutable;

__END__

=head1 NAME

Model::User - описание модели User

=head1 DETAILS

Смотрите L<Moose> для подробностей.

=cut
