package Game::Actions::Lobby;
use strict;
use warnings;

#use Digest::SHA1 ();

use Game::Actions;
use Game::Environment qw(assert compability db db_search db_search_one
                         early_response_json
                         global_user
                         inc_counter
                         init_user_by_sid
                         is_debug if_debug
                         response response_json);
use Game::Model::User;
use Moose::Util::TypeConstraints;

use Exporter::Easy (
    OK => [qw(getUserInfo login logout register)]
);

sub _gen_sid {
    my $sid;

    if (is_debug()) {
        return inc_counter('Game::Model::User::sid');
    }

    while (1) {
        $sid = Digest::SHA1::sha1_hex(rand() . time() .
                                      'secret#$#%#%#%#%@#KJDFSd24');
        last unless (db_search({ sid => $sid })->all());
    }
    $sid
}

sub getUserInfo {
    my ($data) = @_;
    my ($user, $err);

    if (defined $data->{userId}) {
        $user = db_search_one({ CLASS => 'Game::Model::User' },
                              { id => $data->{userId} });
        $err = 'badUserId'
    } elsif (defined $data->{username}) {
        $user = db_search_one({ CLASS => 'Game::Model::User' },
                              { username => $data->{username} });
        $err = 'badUsername'
    } elsif (defined $data->{sid}) {
        init_user_by_sid($data->{sid});
        $user = global_user();
        $err = 'badUserSid'
    } else {
        $err = 'badJson'
    }
    unless ($user) {
        early_response_json({result => $err})
    }
    my $game = $user->activeGame() ? $user->activeGame()->gameId() :
                                     undef;
    my $h = { username => $user->{username},
              activeGame => $game,
              userId => $user->id(),
              result => 'ok' };
    response_json($h)
}

sub login {
    my ($data) = @_;
    proto($data, 'username', 'password');

    my $ok_name = find_type_constraint('Username')->check($data->{username});
    assert($ok_name, 'badUsername');
    my $ok_pass = find_type_constraint('Password')->check($data->{password});
    assert($ok_pass, 'badPassword');

    my @q = ({ username => $data->{username} },
             { CLASS => 'Game::Model::User' });
    my $user = db_search_one(@q);

    assert(defined $user && $user->{password} eq $data->{password},
           'badUsernameOrPassword');

    $user->sid(_gen_sid());
    db->update($user);
    response_json({'result' => 'ok',
                   'sid' => $user->sid(),
                   'userId' => $user->id() });
}

sub logout {
    my ($data) = @_;

    global_user()->sid("");
    db->update(global_user());
    response_json({result => 'ok'});
}

sub register {
    my ($data) = @_;
    proto($data, 'username', 'password');

    my @q = ({ CLASS => 'Game::Model::User' },
             { username => $data->{username} });
    if (db_search(@q)->all()) {
        early_response_json({result => 'usernameTaken'});
    }

    my $user = Game::Model::User->new(params_from_proto());
    db()->insert($user);
    response_json({result => 'ok'})
}


1

__END__

=head1 NAME

Game::Lobby - обработчики для регистрации, аутентификация пользователя

=head1 METHODS

=head2 login

TODO

=head2 logout

TODO

=head2 _gen_sid

Метод генерации сидов:

    $sid = Digest::SHA1::sha1_hex(rand() . time() .
                                  'secret#$#%#%#%#%@#KJDFSd24');

TODO: Для тестирование нужен простой генератор сидов, возвращающий
целый числа. Нужно запоминать последнее сгенерированное число.

=head2 register

Регистрация новыx пользователей.

=cut
