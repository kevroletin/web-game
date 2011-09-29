package Game::Lobby;
use strict;
use warnings;

use Digest::SHA1 ();

use Include::Environment qw(db is_debug if_debug
                            response response_json);
use Model::User;

use Exporter::Easy (
    OK => [qw(login logout register)]
);


sub _gen_sid {
    my $sid;
    return reverse($_[0]) if is_debug();
    while (1) {
        $sid = Digest::SHA1::sha1_hex(rand() . time() .
                                      'secret#$#%#%#%#%@#KJDFSd24');
        my $stream = db()->search({ sid => $sid });
        last unless ($stream->all());
    }
    $sid
}

sub login {
    my ($data) = @_;
    my $query = {username => $data->{username}};
    my @users = db()->search($query)->all();
    if (@users > 1 ) {
        die("multiple users with same name");
    } elsif (@users) {
        my $user = $users[0];
        $user->sid(_gen_sid($user->username()));
        db->store($user);
        if ($user->password() eq $data->{password}) {
            response_json({'result' => 'ok',
                           'sid' => $user->sid() });
            return;
        }
    }
    response_json({result => 'badUsernameOrPassword'});
}

sub logout {
    my ($data) = @_;
    my $query = {sid => $data->{sid}};
    my @users = db()->search($query)->all();
    if (@users > 1 ) {
        die("multiple users with same sid");
    } elsif (@users) {
        $users[0]->sid("");
        db->store($users[0]);
        response_json({'result' => 'ok'});
        return;
    }
    response_json({'result' => 'badSid'});
}

#TODO: вынести в методы класс MODEL::USER
sub _validate_username { $_[0] ? 1 : 0 }

sub _validate_password { $_[0] ? 1 : 0 }

#TODO: валидация имени пользователя и пароля.
sub register {
    my ($data) = @_;
    if (!_validate_username($data->{username})) {
        response_json({result => 'badUsername'})
    } elsif (!_validate_password($data->{password})) {
        response_json({result => 'badPassword'})
    } else {
        my $stream = db()->search({
            username => $data->{username}
        });
        if ($stream->all()) {
            response_json({
                result => 'usernameTaken'
            })
        } else {
            my $user = Model::User->new(
                username => $data->{username},
                password => $data->{password},
            );
            db()->store($user);
            response_json({result => 'ok'})
        }
    }
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
