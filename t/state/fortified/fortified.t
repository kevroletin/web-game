use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::register_two_users_and_create_square_map(
   ['border', 'farmland'], ['border', 'farmland'],   ['border', 'hill'], ['border', 'hill']
);

test('load state',
    {
      action => "loadGame",
      gameName => "loadedGame",
      gameState => {
        activePlayerNum => 0,
        attacksHistory => [],
        berserkDice => undef,
        declineRequested => false,
        dragonAttacked => false,
        enchanted => false,
        features => {},
        friendInfo => undef,
        gotWealthy => false,
        holesPlaced => 0,
        mapId => 1,
        players => [
          {
            activePower => "fortified",
            activeRace => "humans",
            activeState => {
              inDecline => 0,
              tokenBadgeId => -1
            },
            coins => 7,
            id => 1,
            tokensInHand => 5
          },
          {
            coins => 5,
            id => 2,
            tokensInHand => 0
          }
        ],
        raceSelected => false,
        regions => [
          {
            extraItems => {
              fortified => 1
            },
            inDecline => false,
            owner => 1,
            tokensNum => 1
          },
          {
            extraItems => {},
            inDecline => false,
            owner => 1,
            tokensNum => 1
          },
          {
            extraItems => {},
            inDecline => false,
            owner => undef,
            tokensNum => 0
          },
          {
            extraItems => {},
            inDecline => false,
            owner => undef,
            tokensNum => 0
          }
        ],
        state => "conquer",
        turn => 0,
        visibleTokenBadges => [
          {
            bonusMoney => 0,
            raceName => "Sorcerers",
            specialPowerName => "Wealthy"
          },
          {
            bonusMoney => 0,
            raceName => "Elves",
            specialPowerName => "Merchant"
          },
          {
            bonusMoney => 0,
            raceName => "Dwarves",
            specialPowerName => "Mounted"
          },
          {
            bonusMoney => 0,
            raceName => "Humans",
            specialPowerName => "Berserk"
          },
          {
            bonusMoney => 0,
            raceName => "Halflings",
            specialPowerName => "Swamp"
          },
          {
            bonusMoney => 0,
            raceName => "Amazons",
            specialPowerName => "Bivouacking"
          }
        ]
      },
      sid => 1
    },
    {
      result => "ok"
    });

exit();

test('select power',
    {
      action => "selectGivenRace",
      power => "fortified",
      race => "debug",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

test('conquer 1st',
    {
      action => "conquer",
      regionId => 1,
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

test('redeploy 1st',
    {
      action => "redeploy",
      fortified => {
        regionId => 1
      },
      regions => [
        {
          regionId => 1,
          tokensNum => 1
        }
      ],
      sid => undef
    },
    {
      result => "ok"
    },
    $user1 );

test('finish turn: check extra coins',
    {
      action => "finishTurn",
      sid => undef
    },
    {
      coins => 2,
      result => "ok"
    },
    $user1 );

actions()->game_state_to_test({sid => 1, gameId => 1});
