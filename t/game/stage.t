use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

delete $ENV{debug_loading};

#record();

my ($user1, $user2) = Tester::State::register_two_users_and_create_square_map(
  ['border', 'farmland'], ['border', 'farmland'],
  ['border', 'sea'], ['border', 'hill']);

test('create game 1st user',
    {
      action => 'createGame',
      sid => undef,
      gameName => 'game1',
      gameDescr => 'game1 descr',
      mapId =>  undef
    },
    {
      result => 'ok',
      gameId => undef
    },
    $user1 );

$user2->{data}{gameId} = $user1->{data}{gameId};

test('check if 1nd user inGame in games_list',
     {action => 'getGameList', gameId => undef},
     {
      games => [{
                 players => [ {
                               userId => $user1->{data}{userId},
                               inGame => true
                              } ]
                }]
     },
     $user1);

actions->check_magic_game_state('wait', $user1);
actions->check_magic_last_event('wait', $user1);

test('join game 2nd user',
    {
      action => "joinGame",
      gameId => undef,
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

actions->check_magic_game_state('wait', $user1);
actions->check_magic_last_event('wait', $user1);

test('leave game 2nd user',
    {
      action => "leaveGame",
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

actions->check_magic_game_state('wait', $user1);
actions->check_magic_last_event('wait', $user1);

test('join game 2nd user',
    {
      action => "joinGame",
      gameId => undef,
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

test('check if both users inGame in games_list',
     {action => 'getGameList', gameId => undef},
     {
      games => [{
                 players => [ {
                               userId => $user1->{data}{userId},
                               inGame => true
                              },
                              {
                               userId => $user2->{data}{userId},
                               inGame => true
                              } ]
                }]
     },
     $user1);

actions->check_magic_game_state('wait', $user1);
actions->check_magic_last_event('wait', $user1);

test('1st user ready',
    {
      action => "setReadinessStatus",
      isReady => 1,
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_magic_game_state('wait', $user1);
actions->check_magic_last_event('wait', $user1);

test('2nd user ready',
     {
      action => "setReadinessStatus",
      isReady => 1,
      sid => undef,
      visibleRaces => [
                       "Ratmen",
                       "Elves",
                       "Humans",
                       "Amazons",
                       "Dwarves",
                       "Giants",
                       "Halflings",
                       "Orcs",
                       "Skeletons",
                       "Sorcerers",
                       "Tritons",
                       "Trolls",
                       "Wizards"
                      ],
      visibleSpecialPowers => [
                               "Flying",
                               "Forest",
                               "Hill",
                               "Berserk",
                               "Alchemist",
                               "Bivouacking",
                               "Commando",
                               "Diplomat",
                               "DragonMaster",
                               "Fortified",
                               "Heroic",
                               "Merchant",
                               "Mounted",
                               "Pillaging",
                               "Seafaring",
                               "Stout",
                               "Swamp",
                               "Underworld",
                               "Wealthy"
                              ]
     },
     {
      result => "ok"
     },
     $user2 );

actions->check_magic_game_state('begin', $user1);
actions->check_magic_last_event('begin', $user1);

test('select race 1st user',
     {
      action => "selectRace",
      sid => undef,
      position => 1
     },
     { result => 'ok' },
     $user1);

actions->check_magic_game_state('in_game', $user1);
actions->check_magic_last_event('select_race', $user1);

test('conquer',
     {
      action => 'conquer',
      regionId => 2,
      sid => undef
     },
     { result => 'ok' },
     $user1);

actions->check_magic_game_state('in_game', $user1);
actions->check_magic_last_event('conquer', $user1);

test('redeploy',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 2,
          tokensNum => 7
        }
      ],
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_magic_game_state('in_game', $user1);
actions->check_magic_last_event('redeploy', $user1);

test('finish turn',
    {
      action => "finishTurn",
      sid => undef
    },
     {
      statistics => [
                     [
                      "Regions",
                      1
                     ],
                     [
                      "Elves",
                      0
                     ],
                     [
                      "Forest",
                      0
                     ]
                    ],
      result => 'ok'
     },
    $user1 );

actions->check_magic_game_state('in_game', $user1);
actions->check_magic_last_event('finish_turn', $user1);

test('select race 2st user',
     {
      action => "selectRace",
      sid => undef,
      position => 0
     },
     { result => 'ok' },
     $user2);

actions->check_magic_game_state('in_game', $user1);
actions->check_magic_last_event('select_race', $user1);

test('conquer',
     {
      action => 'conquer',
      regionId => 4,
      sid => undef
     },
     { result => 'ok' },
     $user2);

actions->check_magic_game_state('in_game', $user1);
actions->check_magic_last_event('conquer', $user1);

test('redeploy',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 4,
          tokensNum => 12
        }
                 ],
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

actions->check_magic_last_event('redeploy', $user1);

test('finish turn',
    {
      action => "finishTurn",
      sid => undef
    },
    {
     statistics => [
                    [
                     "Regions",
                     1
                    ],
                    [
                     "Ratmen",
                     0
                    ],
                    [
                     "Flying",
                     0
                    ]
                   ],
     result => "ok"
                },
    $user2 );

actions->check_magic_last_event('finish_turn', $user1);

test('qonquer',
     {
      action => 'conquer',
      regionId => 1,
      sid => undef,
     },
     { result => 'ok' },
     $user1);

actions->check_magic_last_event('conquer', $user1);

test('redeploy',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 1,
          tokensNum => 1
        },
        {
          regionId => 2,
          tokensNum => 6
        }
      ],
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_magic_last_event('redeploy', $user1);

test('finish turn',
    {
      action => "finishTurn",
      sid => undef
    },
     {
      statistics => [
                     [
                      "Regions",
                      2
                     ],
                     [
                      "Elves",
                      0
                     ],
                     [
                      "Forest",
                      0
                     ]
                    ],
      result => "ok"
     },
    $user1 );

actions->check_magic_last_event('finish_turn', $user1);

test('decline 2nd',
    {
      action => "decline",
      sid => undef
    },
    {
      result => "ok"
    },
    $user2 );

actions->check_magic_last_event('decline', $user1);

test('finish turn',
    {
      action => "finishTurn",
      sid => undef
    },
 {
  result => "ok",
  statistics => [
    [
      "Regions",
      1
    ],
    [
      "Ratmen",
      0
    ],
    [
      "Flying",
      0
    ]
  ]
},
    $user2 );

actions->check_magic_last_event('finish_turn', $user1);

test('decline 1st',
    {
      action => "decline",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

actions->check_magic_last_event('decline', $user1);

test('finish turn',
    {
      action => "finishTurn",
      sid => undef
    },
     {
      result => "ok"
     },
    $user1 );

actions->check_magic_last_event('finish_turn', $user1);

# TODO: create situation with dice

#replay('http://localhost:5000/engine');

done_testing();
