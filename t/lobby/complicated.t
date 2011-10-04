use strict;
use warnings;

use Test::More tests => 39;

use lib '..';
use Tester;
use Tester::OK;
use Tester::Hooks;


init_logs('lobby/complicated');
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
"result": "badJson"
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
"result": "badJson"
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
"result": "badJson"
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


TEST("Register: bad username(no field)");
GO(
'{
"action": "register",
"password": "password"
}'
,
'{
"result": "badJson"
}'
, {}
);


TEST("Register: bad username(empty)");
GO(
'{
"action": "register",
"username": "",
"password": "password"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("Register: bad username(too short)");
GO(
'{
"action": "register",
"username": "ab",
"password": "password"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("Register: bad username(too long)");
GO(
'{
"action": "register",
"username": "a1234567890123456",
"password": "password"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("Register: bad username(Starts with number)");
GO(
'{
"action": "register",
"username": "1abcde",
"password": "password"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("Register: bad username(contains @)");
GO(
'{
"action": "register",
"username": "Jonh@",
"password": "password"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("Register: user(boundaries1)");
GO(
'{
"action": "register",
"username": "Abcd",
"password": "password"
}'
,
'{
"result": "ok"
}'
, {}
);


TEST("Register: user(boundaries2)");
GO(
'{
"action": "register",
"username": "a123456789012345",
"password": "password"
}'
,
'{
"result": "ok"
}'
, {}
);


TEST("Register: bad username(contains @)");
GO(
'{
"action": "register",
"username": "Jonh@",
"password": "password"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("Register: bad username(contains russian letters)");
GO(
'{
"action": "register",
"username": "Петька",
"password": "password"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("Register: bad password(boundaries1)");
GO(
'{
"action": "register",
"username": "UserPasswd4",
"password": "pas12"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("Register: bad password(boundaries2)");
GO(
'{
"action": "register",
"username": "UserPasswd3",
"password": "1234567890123456789"
}'
,
'{
"result": "badUsernameOrPassword"
}'
, {}
);


TEST("Register: password(boundaries1)");
GO(
'{
"action": "register",
"username": "UserPasswd2",
"password": "!@#$%^&*()!@#$%^&*"
}'
,
'{
"result": "ok"
}'
, {}
);


TEST("Register: password(boundaries2)");
GO(
'{
"action": "register",
"username": "UserPasswd1",
"password": "!@#$%^&*()!@#$%^&*"
}'
,
'{
"result": "ok"
}'
, {}
);
