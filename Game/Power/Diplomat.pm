package Game::Power::Diplomat;
use Moose::Role;

use Game::Environment qw(:std :db :response);

with( 'Game::Roles::Power' );


has 'friendId' => ( isa => 'Maybe[Str]',
                    is => 'rw' );

after 'load_state' => sub {
    my ($self, $state, $owner_user) = @_;
    return unless defined $self->friendId();
    global_game()->raceStateStorage()->{friends} = {
        diplomat => $owner_user->id(),
        friend => $self->friendId()
    };
};

sub power_name { 'diplomat' }

sub _power_tokens_cnt { 5 }

sub __clear_game_state_storage {
    delete global_game()->raceStateStorage()->{friends}
}

after 'conquer' => sub {
    my ($self) = @_;
    if ($self->friendId()) {
        $self->__clear_game_state_storage();
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
    my $public_state = { diplomat => global_user()->id(),
                         friend => $friend->id() };
    global_game()->raceStateStorage()->{friends} = $public_state;
    db()->update($self, global_game())
}

after 'inDecline' => sub {
    my ($self, $val) = @_;
    if ($val && $val == 1) {
        $self->__clear_game_state_storage();
    }
};


1
