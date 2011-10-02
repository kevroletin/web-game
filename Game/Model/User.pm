package Game::Model::User;
use Moose;


has 'sid' => ( isa => 'Str',
               is  => 'rw',
               required => 0 );

has 'name' => ( isa => 'Str',
                is  => 'rw',
                required => 1 );

has 'password' => ( isa => 'Str',
                    is  => 'rw',
                    required => 1 );

sub _db_extractor {
    my ($h, $obj, $extractor, @args) = @_;
    if ($obj->isa(__PACKAGE__)) {
        $h->{sid} = $obj->sid();
        $h->{user_name} = $obj->name();
    }
}

1

__END__

=head1 NAME

Model::User - описание модели User

=head1 DETAILS

Смотрите L<Moose> для подробностей.

=cut

