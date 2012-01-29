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
my $out_file;
unless (shift) {
    $out_file = *STDOUT
} else {
    open $out_file, '>', $filename;
}

my $_ = join ' ', map { chomp; $_ } @content;

/square_map_two_users\(([^()]+)\)/;

if ($1) {
    my $head = <<HEADER
use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my (\$user1, \$user2) = Tester::State::square_map_two_users(
$1
);

HEADER
;
    print $out_file $head;
}


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
    printf $out_file ( "test('%s',\n%s,\n%s,\n%s);",
            $name,
            (map { $_ = Dumper $_; chomp; join "\n", map { "    $_" } split /\n/; }
                    $in, $out),
            '    ' . $params );
}


while (/TEST\(\s*['"]([^'"]*)['"]\s*\)[^']*'([^']*)'[^']*'([^']*)'[,\s]*([^)]+)|([A-Z_]+\([^\)]*\);)/g) {
    if (defined $2) {
        print_test( $1, $2, $3, $4 );
    } else {
        $a = $5;
        $a =~ s/TOKENS_CNT/actions->check_tokens_cnt/;
        print $out_file $a
    }
    print $out_file "\n\n";
}

print $out_file "done_testing();\n"
