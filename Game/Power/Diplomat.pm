package Game::Power::Diplomat;
use Moose::Role;

use Game::Environment qw(:std :db :response);

with( 'Game::Roles::Power' );


has 'friendId' => ( isa => 'Maybe[Str]',
                    is => 'rw' );

after 'friendId' => sub {
    my ($self, $value) = @_;
    $_ = global_game()->raceStateStorage();
    unless (defined $value) {
        delete $_->{friendInfo}
    } else {
        $_->{friendInfo} = { diplomatId => global_user()->id(),
                             friendId   => $value }
    };
};

after 'load_state' => sub {
    my ($self, $state, $owner_user) = @_;
    return unless defined $self->friendId();
    global_game()->raceStateStorage()->{friendInfo} = {
        diplomatId => $owner_user->id(),
        friendId => $self->friendId()
    };
};

sub power_name { 'diplomat' }

sub _power_tokens_cnt { 5 }

after 'conquer' => sub {
    my ($self) = @_;
    if ($self->friendId()) {
        $self->friendId(undef);
        db()->update($self)
    }
};

before 'clear_reg_and_die' => sub {
    my ($self, $reg) = @_;
    if ($self->friendId() &&
        global_user()->id() eq $self->friendId())
    {
        early_response_json({result => 'canNotAttackFriend'})
    }
};

sub selectFriend {
    my ($self, $friend) = @_;
    assert($friend ne global_user(), 'badUser', descr => 'self');
    for (@{global_game()->history()}) {
        assert(!$_->{whom} || $_->{whom} ne $friend, 'badUser',
               descr => 'attacked');
    }
    $self->friendId($friend->id());
    my $public_state = { diplomatId => global_user()->id(),
                         friendId => $friend->id() };
    db()->update($self, global_game())
}

after 'inDecline' => sub {
    my ($self, $val) = @_;
    if ($val && $val == 1) {
        $self->friendId(undef);
    }
};


1
