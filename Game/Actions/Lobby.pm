package Game::Actions::Lobby;
use strict;
use warnings;

use Digest::SHA1 ();

use Game::Environment qw(db db_search early_response_json
                         global_user
                         is_debug if_debug
                         response response_json);
use Game::Model::User;

use Exporter::Easy (
    OK => [qw(login logout register)]
);

sub _gen_sid {
    my $sid;

    if (is_debug()) {
        my ($cnt) = db_search({CLASS => '_sidCounter'})->all();
        if (!$cnt) {
            package _sidCounter;
            use Moose;

            has 'value' => (is => 'rw', isa => 'Int',
                            default => -1);
            no Moose;

            $cnt = _sidCounter->new();
        }
        $cnt->{value}++;
        db->store($cnt);
        return $cnt->{value};
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
    my $q = {user_name => $data->{username}};
    my @users = db_search($q)->all();

    if (@users > 1 ) {
        die("multiple users with same name");
    } elsif (!@users || !defined $data->{password} ||
             $users[0]->password() ne $data->{password})
    {
        response_json({result => 'badUsernameOrPassword'});
        return
    }

    my $user = $users[0];
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
    my $q = {user_name => $data->{username}};
    if (db_search($q)->all()) {
        early_response_json({
            result => 'usernameTaken'
        });
    }
    my $user = Game::Model::User->new(
                   name => $data->{username},
                   password => $data->{password},
               );
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
