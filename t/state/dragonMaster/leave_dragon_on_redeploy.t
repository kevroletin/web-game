use strict;
use warnings;

use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::register_two_users_and_create_square_map(
   ['border', 'farmland'], ['border', 'farmland'],
   ['border', 'hill'], ['border', 'hill']
);

test('load state',
    {
      action => "loadGame",
      gameName => "loadedGame",
      gameState => {
        activePlayerNum => 0,
        attacksHistory => [
          {
            region => 1,
            tokensNum => 2,
            whom => undef
          },
          {
            region => 3,
            tokensNum => 0,
            whom => undef
          },
          {
            region => 4,
            tokensNum => 0,
            whom => undef
          },
          {
            region => 2,
            tokensNum => 0,
            whom => undef
          }
        ],
        berserkDice => undef,
        declineRequested => false,
        dragonAttacked => true,
        enchanted => false,
        features => {},
        friendInfo => undef,
        gotWealthy => false,
        holesPlaced => 0,
        mapId => 1,
        players => [
          {
            activePower => "dragonMaster",
            activeRace => "humans",
            activeState => {
              dragonUsed => 1,
              inDecline => 0,
              tokenBadgeId => -1
            },
            coins => 0,
            id => 1,
            tokensInHand => 3
          },
          {
            coins => 0,
            id => 2,
            tokensInHand => 0
          }
        ],
        raceSelected => false,
        regions => [
          {
            extraItems => {
              dragon => 1
            },
            inDecline => false,
            owner => 1,
            tokensNum => 1
          },
          {
            extraItems => {},
            inDecline => false,
            owner => 1,
            tokensNum => 2
          },
          {
            extraItems => {},
            inDecline => false,
            owner => 1,
            tokensNum => 2
          },
          {
            extraItems => {},
            inDecline => false,
            owner => 1,
            tokensNum => 2
          }
        ],
        state => "conquer",
        turn => 0,
        visibleTokenBadges => [
          {
            bonusMoney => 0,
            raceName => "Dwarves",
            specialPowerName => "Seafaring"
          },
          {
            bonusMoney => 0,
            raceName => "Giants",
            specialPowerName => "Mounted"
          },
          {
            bonusMoney => 0,
            raceName => "Halflings",
            specialPowerName => "Forest"
          },
          {
            bonusMoney => 0,
            raceName => "Skeletons",
            specialPowerName => "Diplomat"
          },
          {
            bonusMoney => 0,
            raceName => "Humans",
            specialPowerName => "Stout"
          },
          {
            bonusMoney => 0,
            raceName => "Amazons",
            specialPowerName => "Merchant"
          }
        ]
      },
      sid => 1
    },
    {
      result => "ok"
    });

exit();

test('redeploy',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 2,
          tokensNum => 2
        },
        {
          regionId => 3,
          tokensNum => 2
        },
        {
          regionId => 4,
          tokensNum => 2
        }
      ],
      sid => 1
    },
    {
      result => "ok"
    });

exit();

test('finishTurn',
    {
      action => "finishTurn",
      sid => 1
    },
    {
      coins => 4,
      result => "ok",
      statistics => [
        [
          "Regions",
          3
        ],
        [
          "Humans",
          1
        ],
        [
          "DragonMaster",
          0
        ]
      ]
    });

done_testing();



