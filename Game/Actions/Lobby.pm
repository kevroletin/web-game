package Game::Actions::Lobby;
use strict;
use warnings;

use Digest::SHA1 ();

use Game::Actions;
use Game::Environment qw(db db_search db_search_one
                         early_response_json
                         global_user
                         inc_counter
                         is_debug if_debug
                         response response_json);
use Game::Model::User;

use Exporter::Easy (
    OK => [qw(login logout register)]
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

sub login {
    my ($data) = @_;
    proto($data, 'username', 'password');

    my @q = ({ username => $data->{username} },
             { password => $data->{password} },
             { CLASS => 'Game::Model::User' });
    my $user = db_search_one(@q);

    unless ($user) {
        early_response_json({result => 'badUsernameOrPassword'});
    }

    $user->sid(_gen_sid());
    db->store($user);
    response_json({'result' => 'ok',
                   'sid' => $user->sid() });
}

sub logout {
    my ($data) = @_;

    global_user()->sid("");
    db->store(global_user());
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
    db()->store($user);
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
