package Game::Model::Message;
use Moose;

use Game::Environment qw(:std :db);
use Moose::Util::TypeConstraints;

our @db_index = qw(messageId);

subtype 'Game::Model::Message::Text',
    as 'Str',
    where { length($_) <= 300 },
    message { assert(0, 'badMessageText') };

has 'messageId' => ( isa => 'Int',
                     is => 'ro',
                     default => sub {
                         inc_counter('Game::Model::Message::id')
                     } );

has 'text' => ( isa => 'Game::Model::Message::Text',
                is => 'rw',
                default => sub { assert(0, 'badMessageText') } );

# Since to get messages we will retrive all messages we shouldn't
# store reference to users here, because with messages we will
# retrive users -> games -> maps = almost all database
has 'username' => ( isa => 'Str',
                    is => 'rw',
                    required => 1 );


__PACKAGE__->meta->make_immutable;
