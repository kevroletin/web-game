use strict;
use warnings;

use Test::More tests => 25;

use lib '..';
use Tester;
use Tester::Hooks;

# TODO: вынести повторяющийся в тестах код

open_log('lobby/complicated.msg');
open my $fout, '>', 'lobby/complicated.log';

sub OK {
    ok($_[0]->{res}, $_[1]);
    print $fout "\n*** $_[1]  ***:  ", $_[0]->{quick} . "\n";
    print $fout $_[0]->{long} . "\n" if $_[0]->{long};
}

my ($descr, $in, $out, $hooks);

sub TEST {
    $descr = $_[0]
}

sub GO {
    $in = $_[0] if $_[0];
    $out = $_[1] if $_[1];
    $hooks = $_[2] if $_[2];
    write_to_log($descr);
    OK( json_compare_test($in, $out, $hooks), $descr );
}


ok( reset_server(), 'reset server' );

TEST("Bad json 1");
GO(
'asdfs;dlkfj'
,
'{
"result": "badJson"
}'
, {}
);


TEST("Bad json 2(empty)");
GO(
''
,
'{
"result": "badJson"
}'
, {}
);


TEST("No action");
GO(
'{ }'
,
'{
"result": "badJson"
}'
, {}
);

TEST("Empty action 1");
GO(
'{ "action" : "" }'
,
'{
"result": "badJson"
}'
, {}
);


TEST("Empty action 2");
GO(
'{ "action" }'
,
'{
"result": "badJson"
}'
, {}
);


TEST("First user register");
GO(
'{
"action": "register",
"username": "user1",
"password": "password1"
}'
,
'{
"result": "ok"
}'
, {}
);


TEST("First user login");

my $sid_1 = '';

GO(
'{
"action": "login",
"username": "user1",
"password": "password1"
}'
,
'{
"result": "ok"
}'
,
   {
    res_hook => sid_to_params($sid_1),
    out_hook => sid_from_params()
   }
);


TEST("Second user register");
GO(
'{
"action": "register",
"username": "user2",
"password": "password1"
}'
,
'{
"result": "ok"
}'
, {}
);


TEST("Second user login");

my $sid_2 = '';

GO(
'{
"action": "login",
"username": "user2",
"password": "password1"
}'
,
'{
"result": "ok"
}'
,
   {
    res_hook => sid_to_params($sid_2),
    out_hook => sid_from_params()
   }
);


ok( $sid_1 ne $sid_2, 'sids differ');


TEST("User1 logout");
GO(
'{
"action": "logout",
"sid": "' . $sid_1 . '"
}'
,
'{
"result": "ok"
}'
, {}
);


TEST("User1 logout twice");
GO(
'{
"action": "logout",
"sid": "' . $sid_1 . '"
}'
,
'{
"result": "badSid"
}'
, {}
);


TEST("User1 doSmth befor login ");
GO(
'{
"action": "doSmth",
"sid": "' . $sid_1 . '"
}'
,
'{
"result": "badSid"
}'
, {}
);


TEST("User2 doSmth ");
GO(
'{
"action": "doSmth",
"sid": "' . $sid_2 . '"
}'
,
'{
"result": "ok"
}'
, {}
);


TEST("Second user login twice");

my $sid_2_new = '';

GO(
'{
"action": "login",
"username": "user2",
"password": "password1"
}'
,
'{
"result": "ok"
}'
,
   {
    res_hook => sid_to_params($sid_2_new),
    out_hook => sid_from_params()
   }
);


TEST("Second user using old sid");
GO(
'{
"action": "doSmth",
"sid": "' . $sid_2 . '"
}'
,
'{
"result": "badSid"
}'
, {}
);

TEST("First user register twice");
GO(
'{
"action": "register",
"username": "user1",
"password": "password1"
}'
,
'{
"result": "usernameTaken"
}'
, {}
);


TEST("First user login whithout password");
GO(
'{
"action": "login",
"username": "user1"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("First user login whithout username");
GO(
'{
"action": "login",
"password": "password1"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("First user login empty password");
GO(
'{
"action": "login",
"username": "user1",
"password": ""
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("First user login empty username");
GO(
'{
"action": "login",
"username": "",
"password": "password1"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("First user login whithout params");
GO(
'{
"action": "login"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("First user login wrond password");
GO(
'{
"action": "login",
"username": "user1",
"password": "password1sdasfdsdf"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("First user login wrond username");
GO(
'{
"action": "login",
"username": "user1sdfsd",
"password": "password1"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);

