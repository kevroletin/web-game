package Tester::OK;
use strict;
use warnings;

use Test::More;
use Tester;
use Exporter::Easy (
    EXPORT => [ qw( OK
                    IN
                    OUT
                    HOOKS
                    TEST
                    GO) ],
);


our ($descr, $in, $out, $hooks) = (('') x 4);

sub OK {
    write_log($_[1]);
    ok($_[0]->{res}, $_[1]);
    $_[0]->{quick} ||= $_[0]->{res} ? 'ok' : 'not ok';
    $_[0]->{long} ||= $_[0]->{quick};
    write_msg("\n*** $_[1]  ***:  ", $_[0]->{quick} . "\n");
    write_msg($_[0]->{long} . "\n") if $_[0]->{long};
}

sub GO {
    $in = $_[0] if $_[0];
    $out = $_[1] if $_[1];
    $hooks = $_[2] if $_[2];
    OK( json_compare_test($in, $out, $hooks), $descr );
}

sub IN { if ($_[0]) { $in = $_[0] } $in  }

sub OUT { if ($_[0]) { $out = $_[0] } $out }

sub HOOKS { if ($_[0]) { $hooks = $_[0] } $hooks }

sub TEST { if ($_[0]) { $descr = $_[0] } $descr }


1
