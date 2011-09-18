package Game::Lobby;
use strict;
use warnings;

use Digest::SHA1 ();

use Include::Enviroment qw(db response_json);
use Model::User;

use Exporter::Easy (
    OK => [qw(login logout register)]
);


sub login {
    my ($data) = @_;
    response->body("login");
}

sub logout {
    my ($data) = @_;
    response->body("logout");
}

sub _validate_username { $_[0] ? 1 : 0 }

sub _validate_password { $_[0] ? 1 : 0 }

sub _gen_sid {
    my $sid;
    while (1) {
        $sid = Digest::SHA1::sha1_hex(rand() . time() .
                                      'secret#$#%#%#%#%@#KJDFSd24');
        my $stream = db()->search({ sid => $sid });
        last if ($stream->is_done() || !$stream->items());
    }
    $sid
}

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
        if (!$stream->is_done() && $stream->items()) {
            response_json({
                result => 'badUsername',
                description => 'already exist',
            })
        } else {
            my $user = Model::User->new(
                username => $data->{username},
                password => $data->{password},
                sid => _gen_sid()
            );
            db()->store($user);
            response_json({result => 'usernameTaken'})
        }
    }
}


1

__END__

=head1 NAME

Game::Lobby - аутенфикация/регистрация
