use warnings;
use strict;

use File::Slurp;

my $fname = shift;
my @data = read_file($fname);

my @res;

while (@data) {
    my $line = shift @data;
    push @res, $line;
    if ($line =~ /^\s*([^\s]+)\s*= function/) {
        $_ = $1;
        push @res, "  log.d.trace('$_');\n\n";
    }
}

write_file($fname, @res);
