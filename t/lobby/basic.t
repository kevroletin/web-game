use strict;
use warnings;

use Test::More tests => 7;

use lib '..';
use Tester;
use Tester::OK;
use Tester::Hooks;


open my $f, '<', 'lobby/basic.json';

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

init_logs('lobby/basic');
reset_server();

my ($descr, $in, $out, $h);
$h = params_same(qw(sid userId));
do {
    if ($in) {
        write_log($descr);
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
    $out = '{ "result": "badUserSid" }';
    OK( json_compare_test($in, $out, $h), "bad pasword error");
}


1;
