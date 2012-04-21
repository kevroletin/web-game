use Tester::New;

my @fields_to_save = ('sid', 'gameId', 'mapId', 'coins',
                      'activeGame', 'userId', 'id');
my ($user1, $user2) =
    map { hooks_sync_values(@fields_to_save) } 1, 2;

test('resetServer',
    {
      action => "resetServer"
    },
    {
      result => "ok"
    });

test('createDefaultMaps',
    {
      action => "createDefaultMaps"
    },
    {
      result => "ok"
    });

test('register',
    {
      action => "register",
      password => "123123",
      username => "user1"
    },
    {
      result => "ok"
    });

test('login',
    {
      action => "login",
      password => "123123",
      username => "user1"
    },
    {
      result => "ok",
      sid => undef,
      userId => undef
    },
    $user1);

test('createGame',
    {
      action => "createGame",
      ai => 1,
      gameDescr => "",
      gameName => "new-game",
      mapId => 1,
      sid => undef
    },
    {
      gameId => 1,
      result => "ok"
    },
    $user1);

test('setReadinessStatus',
    {
      action => "setReadinessStatus",
      isReady => 1,
      sid => undef
    },
    {
      result => "ok"
    },
    $user1);

test('aiJoin',
    {
      action => "aiJoin",
      gameId => 1,
    },
    {
      id => undef,
      result => "ok",
      sid => undef
    },
    $user2);

#test('setReadinessStatus',
#    {
#      action => "setReadinessStatus",
#      isReady => 1,
#      sid => 2
#    },
#    {
#      result => "ok"
#    });

test('selectRace',
    {
      action => "selectRace",
      position => 0,
      sid => undef
    },
    {
      result => "ok",
      tokenBadgeId => 1
    },
    $user1);

test('conquer',
     {"action" => "conquer", "regionId" => 1, "sid" => undef },
    {
      result => "ok",
    },
    $user1);

test('redeploy',
     {"regions" => [{"tokensNum" => 2, "regionId" => 1}],
      "action" => "redeploy",
      "sid" => undef},
#    {
#      action => "redeploy",
#      regions => [],
#      sid => undef
#    },
    {
      result => "ok"
    },
    $user1);

test('finishTurn',
    {
      action => "finishTurn",
      sid => undef
    },
    {
      result => "ok"
    },
    $user1);

done_testing();
