use strict;
#use warnings;

use Test::More;

use lib '..';
use Cwd;
use File::Spec;
use Tester;
use Tester::OK;
use Tester::Hooks;
use File::Slurp q(read_file);
use JSON;

my $import_path = "../../web-game-lena/server/tests";


sub GO {
    IN($_[0]) if $_[0];
    OUT($_[1]) if $_[1];
    HOOKS($_[2]) if $_[2];
    write_log(TEST);
    OK( already_json_test(IN, OUT, HOOKS), TEST );
}

sub SendTests {
    my ($in_p, $out_p, $tests_name) = @_;
    my $in_json = from_json($$in_p);
    my $out_json = from_json($$out_p);

    my $descr = $in_json->{description};
    $descr |= $tests_name;
    my $i = 0;

    while(@{$in_json->{test}}) {
        my $in = shift @{$in_json->{test}};
        my $out = shift @$out_json;
        $in and $out or die "bad test structure";

        TEST("$descr:$i");
        GO($in, $out, {} );

        ++$i;
    }
}

my $log_dir = File::Spec->join(getcwd(), "import");
chdir File::Spec->canonpath($import_path);

my @files = @ARGV;
@files = glob('*.in') unless @files;

for (@files) {
    /^(.*)\.in$/;
    my $base = $1;
    my $in = read_file($_);
    my $out = read_file($base . '.ans');
    init_logs(File::Spec->join($log_dir, $base));
    SendTests(\$in, \$out, $base);
    close_logs();
}

done_testing();
