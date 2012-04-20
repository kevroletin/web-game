use strict;
use warnings;

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
        attacksHistory => [
          {
            region => 1,
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
        dragonAttacked => false,
        enchanted => false,
        features => {},
        friendInfo => undef,
        gotWealthy => false,
        holesPlaced => 0,
        mapId => 1,
        players => [
          {
            activePower => "bivouacking",
            activeRace => "humans",
            activeState => {
              inDecline => 0,
              tokenBadgeId => -1
            },
            coins => 5,
            id => 1,
            tokensInHand => 3
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
              encampment => 1
            },
            inDecline => false,
            owner => 1,
            tokensNum => 1
          },
          {
            extraItems => {
              encampment => 4
            },
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
            raceName => "Tritons",
            specialPowerName => "Swamp"
          },
          {
            bonusMoney => 0,
            raceName => "Giants",
            specialPowerName => "Forest"
          },
          {
            bonusMoney => 0,
            raceName => "Elves",
            specialPowerName => "Fortified"
          },
          {
            bonusMoney => 0,
            raceName => "Orcs",
            specialPowerName => "Pillaging"
          },
          {
            bonusMoney => 0,
            raceName => "Sorcerers",
            specialPowerName => "Hill"
          },
          {
            bonusMoney => 0,
            raceName => "Trolls",
            specialPowerName => "Stout"
          }
        ]
      },
      sid => 1
    },
    {
      result => "ok"
    });

done_testing();
