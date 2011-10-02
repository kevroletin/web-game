package Model::User;
use Moose;

has 'sid' => ( isa => 'Str',
               is  => 'rw',
               required => 0 );

has 'username' => ( isa => 'Str',
                    is  => 'rw',
                    required => 0 );

has 'password' => ( isa => 'Str',
                    is  => 'rw',
                    required => 0 );

sub _db_extractor {
    my ($h, $obj, $extractor, @args) = @_;
    if ($obj->isa("Model::User")) {
        $h->{sid} = $obj->sid();
        $h->{username} = $obj->username();
    }
}

1

__END__

=head1 NAME

Model::User - описание модели User

=head1 DETAILS

Смотрите L<Moose> для подробностей.

=cut

