use strict;
use warnings;

use lib '..';
use Tester::State;
use Tester::New;

my ($user1, $user2) = Tester::State::register_two_users_and_create_square_map(
   ['border', 'farmland'], ['border', 'farmland'],
   ['border', 'hill'], ['border', 'hill']
);

my $state = {
  gameState => {
    activePlayerNum => 0,
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
        activePower => "stout",
        activeRace => "humans",
        activeState => {
          declineRequested => 0,
          inDecline => 0,
          tokenBadgeId => -1
        },
        coins => 5,
        id => 1,
        tokensInHand => 8
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
        raceName => "Humans",
        specialPowerName => "Pillaging"
      },
      {
        bonusMoney => 0,
        raceName => "Sorcerers",
        specialPowerName => "Forest"
      },
      {
        bonusMoney => 0,
        raceName => "Amazons",
        specialPowerName => "DragonMaster"
      },
      {
        bonusMoney => 0,
        raceName => "Dwarves",
        specialPowerName => "Seafaring"
      },
      {
        bonusMoney => 0,
        raceName => "Giants",
        specialPowerName => "Flying"
      },
      {
        bonusMoney => 0,
        raceName => "Tritons",
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
