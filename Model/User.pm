package Model::User;
use Moose;

has 'sid' => ( isa => 'Str',
               is  => 'rw' );

has 'username' => ( isa => 'Str',
                    is  => 'rw',
                    required => 1 );

has 'password' => ( isa => 'Str',
                    is  => 'rw',
                    required => 1 );

1
