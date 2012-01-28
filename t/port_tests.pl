use warnings;
use strict;
use v5.10;

use File::Slurp;
use JSON;
use Data::Dumper::Concise;

use Carp;
$SIG{__DIE__} = sub { Carp::confess @_ };



my $filename = shift;
my @content = read_file($filename);

my $_ = join ' ', map { chomp; $_ } @content;


sub insert_undef {
    my $h = shift;
    for (keys %$h) {
        $h->{$_} = undef if ($h->{$_} eq '')
    }
}

sub print_test {
    my ($name, $in_json, $out_json, $params) = @_;
    $name = lc($name);
    my $in = from_json($in_json);
    my $out = from_json($out_json);
    insert_undef($in);
    insert_undef($out);
    printf( "test('%s',\n%s,\n%s,\n%s);",
            $name,
            (map { $_ = Dumper $_; chomp; join "\n", map { "    $_" } split /\n/; }
                    $in, $out),
            '    ' . $params );
}


while (/TEST\(\s*['"]([^'"]*)['"]\s*\)[^']*'([^']*)'[^']*'([^']*)'[,\s]*([^)]+)|([A-Z_]+\([^\)]*\);)/g) {
    if (defined $2) {
        print_test( $1, $2, $3, $4 );
    } else {
        print $5
    }
    print "\n\n";
}

