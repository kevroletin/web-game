package Model::Configurator;
use strict;
use warnings;

use KiokuDB;

use Include::Enviroment qw(db db_scope);

sub connect_db {
    my $dir = KiokuDB->connect('config/db.yml');
    db($dir);
    db_scope($dir->new_scope());
}


1

__END__


=head1 NAME

Model::Configurator - соединение c БД
