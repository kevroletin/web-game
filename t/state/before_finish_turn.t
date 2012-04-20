use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;


test('',
    {
      action => "resetServer"
    },
    {
      result => "ok"
    });

test('',
    {
      action => "register",
      password => "password1",
      username => "user1"
    },
    {
      result => "ok"
    });

test('',
    {
      action => "login",
      password => "password1",
      username => "user1"
    },
    {
      result => "ok",
      sid => 1,
      userId => 1
    });

test('',
    {
      action => "register",
      password => "password2",
      username => "user2"
    },
    {
      result => "ok"
    });

test('',
    {
      action => "login",
      password => "password2",
      username => "user2"
    },
    {
      result => "ok",
      sid => 2,
      userId => 2
    });

test('',
    {
      action => "createDefaultMaps"
    },
    {
      result => "ok"
    });

test('load state',
    {
      action => "loadGame",
      gameName => "loadedGame",
      gameState => {
        activePlayerNum => 0,
        attacksHistory => [
          {
            region => 4,
            tokensNum => 1,
            whom => undef
          },
          {
            region => 5,
            tokensNum => 0,
            whom => undef
          },
          {
            region => 10,
            tokensNum => 1,
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
        mapId => 3,
        players => [
          {
            activePower => "fortified",
            activeRace => "elves",
            activeState => {
              inDecline => 0,
              tokenBadgeId => -1
            },
            coins => 13,
            declinePower => "dragonMaster",
            declineRace => "trolls",
            declineState => {
              dragonUsed => 0,
              inDecline => 1,
              tokenBadgeId => -1
            },
            id => 1,
            tokensInHand => 0
          },
          {
            coins => 17,
            declinePower => "merchant",
            declineRace => "skeletons",
            declineState => {
              inDecline => 1,
              tokenBadgeId => -1
            },
            id => 2,
            tokensInHand => 0
          }
        ],
        raceSelected => false,
        regions => [
          {
            extraItems => {},
            inDecline => true,
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
            inDecline => true,
            owner => 1,
            tokensNum => 1
          },
          {
            extraItems => {},
            inDecline => false,
            owner => 1,
            tokensNum => 3
          },
          {
            extraItems => {},
            inDecline => false,
            owner => 1,
            tokensNum => 2
          },
          {
            extraItems => {},
            inDecline => true,
            owner => 1,
            tokensNum => 1
          },
          {
            extraItems => {},
            inDecline => true,
            owner => 1,
            tokensNum => 1
          },
          {
            extraItems => {},
            inDecline => false,
            owner => undef,
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
            owner => 1,
            tokensNum => 4
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
          },
          {
            extraItems => {},
            inDecline => false,
            owner => undef,
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
            inDecline => true,
            owner => 2,
            tokensNum => 1
          },
          {
            extraItems => {},
            inDecline => true,
            owner => 2,
            tokensNum => 1
          },
          {
            extraItems => {},
            inDecline => true,
            owner => 2,
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
            tokensNum => 1
          },
          {
            extraItems => {},
            inDecline => false,
            owner => undef,
            tokensNum => 0
          }
        ],
        state => "conquer",
        turn => 2,
        visibleTokenBadges => [
          {
            bonusMoney => 0,
            raceName => "Dwarves",
            specialPowerName => "Wealthy"
          },
          {
            bonusMoney => 0,
            raceName => "Humans",
            specialPowerName => "Merchant"
          },
          {
            bonusMoney => 0,
            raceName => "Ratmen",
            specialPowerName => "Stout"
          },
          {
            bonusMoney => 0,
            raceName => "Tritons",
            specialPowerName => "Commando"
          },
          {
            bonusMoney => 0,
            raceName => "Giants",
            specialPowerName => "Diplomat"
          },
          {
            bonusMoney => 0,
            raceName => "Wizards",
            specialPowerName => "Hill"
          }
        ]
      },
      sid => 1
    },
    {
      result => "ok"
    });

exit();

test('create game 1st user',
    {
      action => 'createGame',
      sid => 1,
      gameName => 'game1',
      gameDescr => 'game1 descr',
      mapId =>  3
    },
    {
      result => 'ok',
      gameId => 1
    });

test('',
    {
      action => "setReadinessStatus",
      isReady => 1,
      sid => 1
    },
    {
      result => "ok"
    });

test('',
    {
      action => "joinGame",
      gameId => 1,
      sid => 2
    },
    {
      result => "ok"
    });

test('',
    {
      action => "setReadinessStatus",
      isReady => 1,
      sid => 2
    },
    {
      result => "ok"
    });

test('',
    {
      action => "selectGivenRace",
      race => 'trolls',
      power => 'dragonMaster',
      sid => 1
    },
    {
      result => "ok"
    });

test('',
    {
      action => "conquer",
      regionId => 1,
      sid => 1
    },
    {
      dice => undef,
      result => "ok"
    });

test('',
    {
      action => "conquer",
      regionId => 6,
      sid => 1
    },
    {
      dice => undef,
      result => "ok"
    });

test('',
    {
      action => "conquer",
      regionId => 7,
      sid => 1
    },
    {
      dice => undef,
      result => "ok"
    });

test('',
    {
      action => "conquer",
      regionId => 3,
      sid => 1
    },
    {
      dice => undef,
      result => "ok"
    });

test('',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 1,
          tokensNum => 2
        },
        {
          regionId => 3,
          tokensNum => 2
        },
        {
          regionId => 6,
          tokensNum => 2
        },
        {
          regionId => 7,
          tokensNum => 3
        }
      ],
      sid => 1
    },
    {
      result => "ok"
    });

test('',
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
          4
        ],
        [
          "Trolls",
          0
        ],
        [
          "DragonMaster",
          0
        ]
      ]
    });

test('',
    {
      action => "selectGivenRace",
      race => 'skeletons',
      power => 'merchant',
      sid => 2
    },
    {
      result => "ok",
    });

test('',
    {
      action => "conquer",
      regionId => 16,
      sid => 2
    },
    {
      dice => undef,
      result => "ok"
    });

test('',
    {
      action => "conquer",
      regionId => 15,
      sid => 2
    },
    {
      dice => undef,
      result => "ok"
    });

test('',
    {
      action => "conquer",
      regionId => 17,
      sid => 2,
      dice => 2
    },
    {
      dice => 2,
      result => "ok"
    });

test('',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 15,
          tokensNum => 3
        },
        {
          regionId => 16,
          tokensNum => 3
        },
        {
          regionId => 17,
          tokensNum => 1
        }
      ],
      sid => 2
    },
    {
      result => "ok"
    });

test('',
    {
      action => "finishTurn",
      sid => 2
    },
    {
      coins => 6,
      result => "ok",
      statistics => [
        [
          "Regions",
          3
        ],
        [
          "Skeletons",
          0
        ],
        [
          "Merchant",
          3
        ]
      ]
    });

test('',
    {
      action => "decline",
      sid => 1
    },
    {
      result => "ok"
    });

test('',
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
          4
        ],
        [
          "Trolls",
          0
        ],
        [
          "DragonMaster",
          0
        ]
      ]
    });

test('',
    {
      action => "decline",
      sid => 2
    },
    {
      result => "ok"
    });

test('',
    {
      action => "finishTurn",
      sid => 2
    },
    {
      coins => 6,
      result => "ok",
      statistics => [
        [
          "Regions",
          3
        ],
        [
          "Skeletons",
          0
        ],
        [
          "Merchant",
          0
        ]
      ]
    });

test('',
    {
      action => "selectGivenRace",
      race => "elves",
      power => "fortified",
      sid => 1
    },
    {
      result => "ok"
    });

test('',
    {
      action => "conquer",
      regionId => 4,
      sid => 1
    },
    {
      dice => undef,
      result => "ok"
    });

test('',
    {
      action => "conquer",
      regionId => 5,
      sid => 1
    },
    {
      dice => undef,
      result => "ok"
    });

test('',
    {
      action => "conquer",
      regionId => 10,
      sid => 1
    },
    {
      dice => undef,
      result => "ok"
    });

actions()->game_state_to_test({sid => 1, gameId => 1});

exit();

test('',
    {
      action => "redeploy",
      regions => [
        {
          regionId => 4,
          tokensNum => 3
        },
        {
          regionId => 5,
          tokensNum => 2
        },
        {
          regionId => 10,
          tokensNum => 4
        }
      ],
      sid => 1
    },
    {
      result => "ok"
    });

if (0) {

test('',
    {
      action => "finishTurn",
      sid => 1
    },
    {
      coins => 3,
      result => "ok",
      statistics => [
        [
          "Regions",
          3
        ],
        [
          "Elves",
          0
        ],
        [
          "Fortified",
          0
        ]
      ]
    });
}

done_testing();
