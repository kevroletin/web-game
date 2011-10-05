package Game::Model::User;
use Moose;

use Game::Environment qw(early_response_json);


our @db_index = qw(sid name password);

has 'sid' => ( isa => 'Str',
               is  => 'rw',
               required => 0 );

has 'name' => ( isa => 'Str|Undef',
                is  => 'rw',
                required => 1,
                  );

has 'password' => ( isa => 'Str|Undef',
                    is  => 'rw',
                    required => 1 );

sub BUILD {
    _validate_name( $_[0]->{name} );
    _validate_password( $_[0]->{password} );
}

before 'name' => sub {
    my $val = $_[1];
    defined $val and _validate_name($val)
};

before 'password' => sub {
    my $val = $_[1];
    defined $val and _validate_password($val)
};

sub _validate_name {
    unless (defined $_[0] &&
            $_[0] =~ /^[A-Za-z][A-Za-z0-9\_\-]{2,15}$/) {
        early_response_json({result => 'badUsername'})
    }
}

sub _validate_password {
    unless (defined $_[0] &&
            $_[0] =~ /^.{6,18}$/) {
        early_response_json({result => 'badPassword'})
    }
}


1

__END__

=head1 NAME

Model::User - описание модели User

=head1 DETAILS

Смотрите L<Moose> для подробностей.

=cut

