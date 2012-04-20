use strict;
use warnings;

use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::register_two_users_and_create_square_map(
   ['border', 'mountain'], ['border', 'farmland'],
   ['border', 'hill'], ['border', 'hill']
);

my $state = {
  gameState => {
    activePlayerNum => 1,
    attacksHistory => [
      {
        region => 1,
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
        activePower => "forest",
        activeRace => "humans",
        activeState => {
          inDecline => 0,
          tokenBadgeId => -1
        },
        coins => 7,
        id => 1,
        tokensInHand => 8
      },
      {
        activePower => "diplomat",
        activeRace => "elves",
        activeState => {
          inDecline => 0,
          tokenBadgeId => -1
        },
        coins => 5,
        id => 2,
        tokensInHand => 10
      }
    ],
    raceSelected => false,
    regions => [
      {
        extraItems => {},
        inDecline => false,
        owner => 2,
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
    state => "redeployed",
    turn => 0,
    visibleTokenBadges => [
      {
        bonusMoney => 0,
        raceName => "Tritons",
        specialPowerName => "Heroic"
      },
      {
        bonusMoney => 0,
        raceName => "Giants",
        specialPowerName => "Stout"
      },
      {
        bonusMoney => 0,
        raceName => "Sorcerers",
        specialPowerName => "Hill"
      },
      {
        bonusMoney => 0,
        raceName => "Dwarves",
        specialPowerName => "Diplomat"
      },
      {
        bonusMoney => 0,
        raceName => "Ratmen",
        specialPowerName => "DragonMaster"
      },
      {
        bonusMoney => 0,
        raceName => "Orcs",
        specialPowerName => "Underworld"
      }
    ]
  },
  result => "ok"
};

test( 'load state',
      { action    => 'loadGame',
        sid       => undef,
        gameName  => 'loadedGame',
        gameState => $state->{gameState} },
      { result => 'ok',
        gameId => undef },
      $user1 );

done_testing();
