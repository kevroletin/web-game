use Tester::New;

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
      password => 123123,
      username => "user1"
    },
    {
      result => "ok"
    });

test('login',
    {
      action => "login",
      password => 123123,
      username => "user1"
    },
    {
      result => "ok",
      sid => 1,
      userId => 1
    });

test('createGame',
    {
      action => "createGame",
      ai => 1,
      gameDescr => "",
      gameName => "new-game",
      mapId => 3,
      sid => 1
    },
    {
      gameId => 1,
      result => "ok"
    });

test('setReadinessStatus',
    {
      action => "setReadinessStatus",
      isReady => 1,
      sid => 1
    },
    {
      result => "ok"
    });

test('aiJoin',
    {
      action => "aiJoin",
      gameId => 1,
      sid => undef
    },
    {
      id => 2,
      result => "ok",
      sid => 2
    });

test('setReadinessStatus',
    {
      action => "setReadinessStatus",
      isReady => 1,
      sid => 2
    },
    {
      result => "ok"
    });

test('selectRace',
    {
      action => "selectRace",
      position => 0,
      sid => 1
    },
    {
      result => "ok",
      tokenBadgeId => 1
    });

test('redeploy',
    {
      action => "redeploy",
      regions => [],
      sid => 1
    },
    {
      result => "ok"
    });

test('finishTurn',
    {
      action => "finishTurn",
      sid => 1
    },
    {
      coins => 0,
      result => "ok"
    });

done_testing();
