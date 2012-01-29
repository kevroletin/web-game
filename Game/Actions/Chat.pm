package Game::Actions::Chat;
use strict;
use warnings;

use Game::Actions;
use Game::Environment qw(:db :response);
use Game::Model::Message;

use Exporter::Easy (
    OK => [qw(getMessages sendMessage)]
);


sub getMessages {
    my ($data) = @_;
    proto($data, 'since');
    assert($data->{since} >= 0, 'badSince');

    # Where is no Api in Search::GIN to create queries with inequality.
    my $extract = sub {
        my $s = shift;
        {
            id => $s->{messageId},
            time => $s->{messageId},
            text => $s->{text},
            username => $s->username()
        }
    };
    my $msg = [
        map { $extract->($_) }
            sort { $a->{messageId} <=> $b->{messageId} }
               grep { $_->{messageId} > $data->{since} }
                   db_search({CLASS => 'Game::Model::Message'})->all()
    ];

    response_json({result => 'ok', messages => $msg});
}

sub sendMessage {
    my ($data) = @_;
    assert(defined $data->{text}, 'badMessageText');

    my $msg = Game::Model::Message->new(
                  username => global_user()->username(),
                  text => $data->{text}
              );
    db()->insert_nonroot($msg);

    response_json({result => 'ok'});
}

1
