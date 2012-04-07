
function compatibility_mapper_type() {}
var CompMapper = compatibility_mapper_type.prototype;
var compatibility_mapper = new compatibility_mapper_type;

CompMapper.fix_game_state = function(gs) {
  CompMapper._fix_players_in_place(gs);
  for (var i in gs.players) {
    if (gs.players[i].id == gs.activePlayerId) {
      gs.activePlayerNum = i;
    }
  }
  CompMapper._fix_map_in_place(gs);
  CompMapper._fix_state_field_in_place(gs);
  gs.turn = gs.currentTurn;
};

CompMapper._fix_map_in_place = function(gs) {
  gs.mapId = gs.map.mapId;
  gs.mapName = gs.map.mapName;
  gs.maxPlayersNum = gs.map.playersNum;
  gs.playersNum = gs.players.length;
  gs.turnsNum = gs.map.turnsNum;

  gs.map.regions.forEach(CompMapper._fix_region_in_place);
  gs.regions = gs.map.regions;
};

CompMapper._fix_region_in_place = function(reg) {
  reg.landDescription = reg.constRegionState;

  if (!is_null(reg.currentRegionState)) {
    reg.inDecline = reg.currentRegionState.inDecline;
    reg.owner = reg.currentRegionState.ownerId;
    reg.extraItems = reg.currentRegionState;
    reg.tokensNum = reg.currentRegionState.tokensNum;
  }
};

CompMapper._fix_players_in_place = function(st) {
  st.players.forEach(function(player) {
    player.name = player.username;
    player.id   = player.userId;
    player.readinessStatus = player.isReady;
    if (!is_null(player.currentTokenBadge)) {
      player.activeRace = player.currentTokenBadge.raceName.toLowerCase();
      player.activePower = player.currentTokenBadge.specialPowerName.toLowerCase();
    }
    if (!is_null(player.declinedTokenBadge)) {
      player.declineRace = player.declinedTokenBadge.raceName.toLowerCase();
      player.declinePower = player.declinedTokenBadge.specialPowerName.toLowerCase();
    }
  });
};

CompMapper.state_to_int = {
  wait    : 1,
  begin   : 0,
  in_game : 2,
  finish  : 3,
  empty   : 4
};

CompMapper.int_to_state = {
  1 : 'wait',
  0 : 'begin',
  2 : 'in_game',
  3 : 'finish',
  4 : 'empty'
};

CompMapper._fix_state_field_in_place = function(game_state) {
  var res = CompMapper.get_game_state_fields(game_state.lastEvent,
                                             game_state.state);
  ['state', 'raceSelected', 'attacksHistory', 'lastDiceValue'].forEach(function(k) {
    game_state[k] = res[k];
  });
  if (game_state.defendingInfo) {
    var di = game_state.defendingInfo;
    game_state.state = 'defend';
    game_state.attacksHistory = [{ who    : game_state.activePlayerId, 
                                   whom   : di.playerId,
                                   region : di.regionId }];
  }
};

CompMapper.int_to_last_event = {
  1 : 'wait',
  2 : 'in_game',
  4 : 'finishTurn',
  5 : 'selectRace',
  6 : 'conquer',
  7 : 'decline',
  8 : 'redeploy',
  9 : 'throwDice',
  12: 'defend',
  13: 'selectFriend',
  14: 'failed_conquer'
};

CompMapper.get_game_state_fields = function(last_event_int, state_int) {
  var last_event = CompMapper.int_to_last_event[last_event_int];
  var state = CompMapper.int_to_state[state_int];
  var result = { attacksHistory: [], raceSelected: false };

  if (log_config.convertions) {
    log.d.info('last_event: ' + last_event + '(' + last_event_int + ')');
    log.d.info('state: ' + state + '(' + state_int + ')');
  }

  if (state == 'wait') {
    result.state = 'notStarted';
  } else if (state == 'finish' || state == 'empty') {
    result.state = 'finished';
  } else if (last_event == 'finishTurn') {
    result.state = 'conquer';
    result.raceSelected = false;
  } else if (last_event == 'selectRace') {
    result.state = 'conquer';
    result.raceSelected = true;
  } else if (last_event == 'conquer') {
    result.state = 'conquer';
    result.raceSelected = true;
    result.attacksHistory = [{}];
  } else if (last_event == 'decline') {
    result.state = 'declined';
  } else if (last_event == 'redeploy') {
    result.state = 'redeployed';
  } else if (last_event == 'throwDice') {
    result.state = 'conquer';
  } else if (last_event == 'defend') {
    result.state = 'conquer';
  } else if (last_event == 'selectFriend') {
    result.state = 'redeployed';
  } else if (last_event == 'failed_conquer') {
    result.state = 'conquer';
    result.lastDiceValue = 'used';
    result.attacksHistory = [{}];
  } else {
    if (state == 'begin') {
      result.state = 'conquer';
    } else {
      log.d.error('can\'t obtain game state field');
      result.state = state;
    }
  }

  if (log_config.convertions) {
    log.d.info('state: ' + result.state);
    log.d.info('raceSelected: ' + result.raceSelected);
    log.d.info('attacksHistory: ' + result.attacksHistory);
  }

  return result;
};

CompMapper.fix_game_list = function(games_list) {
  games_list.forEach(function(game) {
    var res = CompMapper.get_game_state_fields(null, game.state);
    game.state = res.state;
    if (is_null(game.gameDescr)) { game.gameDescr = ''; }
    game.playersNum = game.players.length;
  });
};
