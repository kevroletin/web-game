use strict;
use warnings;

use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::register_two_users_and_create_square_map(
   ['border', 'farmland'], ['border', 'farmland'],
   ['border', 'hill'], ['border', 'hill']
);

my $state = {
  gameState => {
    activePlayerNum => 1,
    attacksHistory => [
      {
        region => 3,
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
    mapId => $user1->{data}{mapId},
    players => [
      {
        activePower => "debug",
        activeRace => "humans",
        activeState => {
          inDecline => 0,
          tokenBadgeId => -1
        },
        coins => 7,
        id => 1,
        tokensInHand => 3
      },
      {
        activePower => "debug",
        activeRace => "sorcerers",
        activeState => {
          enchanted => 0,
          inDecline => 0,
          tokenBadgeId => -1
        },
        coins => 5,
        id => 2,
        tokensInHand => 3
      }
    ],
    raceSelected => false,
    regions => [
      {
        extraItems => {},
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
        owner => 2,
        tokensNum => 2
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
        raceName => "Ratmen",
        specialPowerName => "Bivouacking"
      },
      {
        bonusMoney => 0,
        raceName => "Tritons",
        specialPowerName => "Flying"
      },
      {
        bonusMoney => 0,
        raceName => "Dwarves",
        specialPowerName => "Wealthy"
      },
      {
        bonusMoney => 0,
        raceName => "Elves",
        specialPowerName => "Diplomat"
      },
      {
        bonusMoney => 0,
        raceName => "Amazons",
        specialPowerName => "Fortified"
      },
      {
        bonusMoney => 0,
        raceName => "Humans",
        specialPowerName => "Merchant"
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
