package Game::Model::Counter;
use Moose;

our @db_index = qw(name);


has 'name' => ( isa => 'Str', is => 'rw' );

has 'value' => ( isa => 'Int', is => 'rw', default => 0 );

sub next {
    my ($self) = @_;
    ++$self->{value}
}


1
