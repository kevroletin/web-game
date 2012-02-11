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
    activePlayerNum => 0,
    attacksHistory => [
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
        activePower => "dragonMaster",
        activeRace => "humans",
        activeState => {
          dragonUsed => 0,
          inDecline => 0,
          tokenBadgeId => -1
        },
        coins => 0,
        id => 1,
        tokensInHand => 10
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
        extraItems => {},
        inDecline => false,
        owner => undef,
        tokensNum => 2
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



