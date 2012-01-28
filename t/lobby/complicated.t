use strict;
use warnings;

use lib '..';
use Tester::New;

my ($user1, $user2) = map { hooks_sync_values(qw(sid userId)) } 1 .. 2;

test("reset server", {action => 'resetServer'}, { result => 'ok' });

test("bad json 1",
     'asdfs;dlkfj',
     { result => 'badJson' });

test("bad json 2(empty)",
     '',
     {result => "badJson"});

test("no action",
     '{ }',
     {result => "badJson"});

test("empty action 1",
     '{ "action" : "" }',
     {result => "badJson"});

test("empty action 2",
     '{ "action" }',
     {result => "badJson"});

test("first user register",
     {action => 'register',
      username => 'user1',
      password => 'password1'},
     {result => 'ok'});

test("first user login",
     {action => "login",
      username => "user1",
      password => "password1"},
     {result => "ok",
      sid => undef,
      userId => undef},
     $user1);

test('second user register',
    {
      action => "register",
      password => "password1",
      username => "user2"
    },
    {
      result => "ok"
    },
    {} );

test('second user login',
    {
      action => "login",
      password => "password1",
      username => "user2"
    },
    {
      result => "ok",
      sid => undef,
      userId => undef
    },
    $user2 );

ok( $user1->{data}{sid} ne $user2->{data}{sid}, 'sids differ');

test('user1 logout',
    {
      action => "logout",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

test('user1 logout twice',
    {
      action => "logout",
      sid => undef
    },
    {
      result => "badUserSid"
    },
    $user1 );

test('user1 dosmth befor login ',
    {
      action => "doSmth",
      sid => undef
    },
    {
      result => "badUserSid"
    },
    $user1 );

test('user2 dosmth',
    {
      action => "doSmth",
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

test('second user login twice',
    {
      action => "login",
      password => "password1",
      username => "user2"
    },
    {
      result => "ok",
      sid => undef,
      userId => undef
    },
    $user2 );

test('second user using old sid',
    {
      action => "doSmth",
      sid => undef
    },
    {
      result => "badUserSid"
    },
    $user1 );

test('first user register twice',
    {
      action => "register",
      password => "password1",
      username => "user1"
    },
    {
      result => "usernameTaken"
    },
    {} );

test('first user login whithout password',
    {
      action => "login",
      username => "user1"
    },
    {
      result => "badPassword"
    },
    {} );

test('first user login whithout username',
    {
      action => "login",
      password => "password1"
    },
    {
      result => "badUsername"
    },
    {} );

test('first user login empty password',
    {
      action => "login",
      password => undef,
      username => "user1"
    },
    {
      result => "badPassword"
    },
    {} );

test('first user login empty username',
    {
      action => "login",
      password => "password1",
      username => undef
    },
    {
      result => "badUsername"
    },
    {} );

test('first user login wrond password',
    {
      action => "login",
      password => "password1sdasfdsdf",
      username => "user1"
    },
    {
      result => "badUsernameOrPassword"
    },
    {} );

test('first user login wrond username',
    {
      action => "login",
      password => "password1",
      username => "user1sdfsd"
    },
    {
      result => "badUsernameOrPassword"
    },
    {} );

test('register: bad username(no field)',
    {
      action => "register",
      password => "password"
    },
    {
      result => "badUsername"
    },
    {} );

test('register: bad username(empty)',
    {
      action => "register",
      password => "password",
      username => undef
    },
    {
      result => "badUsername"
    },
    {} );

test('register: bad username(too short)',
    {
      action => "register",
      password => "password",
      username => "ab"
    },
    {
      result => "badUsername"
    },
    {} );

test('register: bad username(too long)',
    {
      action => "register",
      password => "password",
      username => "a1234567890123456"
    },
    {
      result => "badUsername"
    },
    {} );

test('register: bad username(starts with number)',
    {
      action => "register",
      password => "password",
      username => "1abcde"
    },
    {
      result => "badUsername"
    },
    {} );

test('register: bad username(contains @)',
    {
      action => "register",
      password => "password",
      username => "Jonh\@"
    },
    {
      result => "badUsername"
    },
    {} );

test('register: bad username(as ai)',
    {
      action => "register",
      password => "password",
      username => "_ai1.1"
    },
    {
      result => "badUsername"
    });

test('register: user(boundaries1)',
    {
      action => "register",
      password => "password",
      username => "Abcd"
    },
    {
      result => "ok"
    },
    {} );

test('register: user(boundaries2)',
    {
      action => "register",
      password => "password",
      username => "a123456789012345"
    },
    {
      result => "ok"
    },
    {} );

test('register: bad username(contains russian letters)',
    {
      action => "register",
      password => "password",
      username => "\x{d0}\x{9f}\x{d0}\x{b5}\x{d1}\x{82}\x{d1}\x{8c}\x{d0}\x{ba}\x{d0}\x{b0}"
    },
    {
      result => "badUsername"
    },
    {} );

test('register: bad password(boundaries1)',
    {
      action => "register",
      password => "pas12",
      username => "UserPasswd4"
    },
    {
      result => "badPassword"
    },
    {} );

test('register: bad password(boundaries2)',
    {
      action => "register",
      password => "1234567890123456789",
      username => "UserPasswd3"
    },
    {
      result => "badPassword"
    },
    {} );

test('register: password(boundaries1)',
    {
      action => "register",
      password => "!\@#\$%^&*()!\@#\$%^&*",
      username => "UserPasswd2"
    },
    {
      result => "ok"
    },
    {} );

test('register: password(boundaries2)',
    {
      action => "register",
      password => "!\@#\$%^&*()!\@#\$%^&*",
      username => "UserPasswd1"
    },
    {
      result => "ok"
    },
    {} );

done_testing();
