use strict;
use warnings;

use Test::More tests => 7;

use lib '..';
use Tester;
use Tester::Hooks;

# TODO: вынести повторяющийся в тестах код

open_log('lobby/basic.msg');
open my $f, '<', 'lobby/basic.json';
open my $fout, '>', 'lobby/basic.log';


sub OK {
    ok($_[0]->{res}, $_[1]);
    print $fout "\n*** $_[1]  ***:  ", $_[0]->{quick} . "\n";
    print $fout $_[0]->{long} . "\n" if $_[0]->{long};
}

sub get_block {
    my $in = "";
    while (<$f>) {
        if (/^#.*/ || /^\s*$/) {
            last if $in;
            next
        }
        $in .= $_
    }
    $in
}

reset_server();

my ($descr, $in, $out, $h);
$h = params_same_sid();
do {
    if ($in) {
        write_to_log($descr);
        OK( json_compare_test($in, $out, $h), $descr );
    }
    $descr = get_block(); substr($descr, 0, 1) = '';
    chomp($descr);
    $in = get_block();
    $out = get_block();
    die "odd number of block in file" if $in && !$out;
} while ($in);


{   # error in logout
    # get sid
    $in = '{
"action": "login",
"username": "user",
"password": "password"
}';
    $out = '{
"result": "ok",
"sid": ""
}';
    json_compare_test($in, $out, $h);

    #bad sid
    $h->{in_hook} = sub {
        $_[0]->{sid} = $_[1]->{_sid} . 'exstra str';
    };
    $in = '{
"action": "logout"
}';
    $out = '{ "result": "badSid" }';
    OK( json_compare_test($in, $out, $h), "bad pasword error");
}


1;
