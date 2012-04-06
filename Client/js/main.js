
var ui = {};

ui.create_menu = function() {
  var modes_list =
    major_modes.available_modes();
  var m = ui_elements.menu(modes_list);
  d3.select('div#menu').text('').node().appendChild(m);
};

function game_type() {}
var Game = game_type.prototype;
var game = new game_type();

Game.init = function() {
  log.d.trace('Game.init');

  events.reg_h('login.success', 'ui_set_logined_mode',
               function() { minor_modes.disable('in_game');
                     minor_modes.enable('logined');
                   });

  events.reg_h('user_info.success', 'ui_fix_in_game_mode',
               function(resp) {
                 if (is_null(state.get('gameId'))) {
                   minor_modes.disable('in_game');
                 } else {
                   minor_modes.enable('in_game');
                 }
               });

  events.reg_h('logout.success', 'ui_disable_logined_mode',
               function() { minor_modes.disable('logined');
                     /* ui.disable_minor_mode('in_game'); */ });

  events.reg_h('game.ui_initialized', 'start main loop',
               game.request_game_state );
  events.reg_h('ui.refresh_menu', 'ui_create_menu',
               ui.create_menu);

  if (is_null(config.predefined_user)) {
    major_modes.change('login');
  } else {
    state.store('sid', config.predefined_user.sid);
    minor_modes.enable('logined');
    if (!is_null(config.predefined_user.gameId)) {
      state.store('gameId', config.predefined_user.gameId)

      game.get_current_user_info()
      minor_modes.enable('in_game');
      major_modes.change('play_game');
    }
  }

  log.d.info('Game core initialized');
};

Game.get_current_user_info = function() {
  log.d.trace('Game.get_current_user_info');

  if (features.getUserInfo) {
    var q = { action: "getUserInfo" };
    var h = function(resp) {
      if (errors.descr_resp(resp) !== 'ok') { return }
      state.store('net.getUserInfo', resp);
      state.store('gameId', resp.activeGame);
      state.store('userId', resp.userId);
      state.store('username', resp.username);
      events.exec('user_info.success');
    };
    net.send(q, h);
  } else {
    var q = { action: "getGameList" };
    var h = function(resp) {
      state.store('net.getGameList', resp);
      if (errors.descr_resp(resp) == 'ok') {
        resp.games.forEach(function(game) {
          game.players.forEach(function(player) {
            if (player.userId == state.get('userId')) {
              state.store('gameId', game.gameId);
              state.store('username', player.username);
              events.exec('user_info.success');
            }
          })
        });
      }
    };
    net.send(q, h);
  }
};

Game.fix_minor_mode_from_game_state = function() {
  log.d.trace('Game.fix_minor_mode_from_game_state');

  var game_state = Game.last_game_state();

  if (!is_null(game_state)) {
    minor_modes.enable('in_game');
  } else {
    minor_modes.disable('in_game');
  }

  state_field = game_state.state;

  if (state_field == 'notStarted') {
    minor_modes.disable('game_started');
    minor_modes.enable('waiting');
    return;
  }

  if (state_field == 'finished') {
    var show_msg = minor_modes.is_enabled('game_started');
    minor_modes.force('finished', show_msg);
    return;
  }

  var new_modes = {
    berserk: 0,
    can_do_redeploy: 0,
    conquer: 0,
    decline: 0,
    defend: 0,
    dragon: 0,
    enchant: 0,
    finished: 0,
    redeploy: 0,
    redeployed: 0,
    select_race: 0,
    waiting: 0,
  };

  minor_modes.enable('game_started');
  if (game.active_player_id() != state.get('userId')) {
    minor_modes.force('waiting');
  } else {
    var a = {
      conquer: function() {
        if (game_state.attacksHistory.length == 0) {
          if (is_null(game.active_player().activeRace)) {
            new_modes['select_race'] = 1
          } else if(!game_state.raceSelected) {
            new_modes['decline'] = 1
          }
        }
        if (game.active_player().activeRace == 'sorcerers' &&
            !game_state.enchanted)
        {
          new_modes['enchant'] = 1;
        }
        if (game.active_player().activePower == 'dragonMaster' &&
            !game_state.dragonAttacked)
        {
          new_modes['dragon'] = 1;
        }
        if (game.active_player().activePower == 'berserk' &&
            is_null(game_state.berserkDice))
        {
          new_modes['berserk'] = 1;
        }

        new_modes['can_do_redeploy'] = !new_modes['select_race'];

        new_modes['conquer'] = 1;
        minor_modes.force('conquer');
      },
      defend: function() { new_modes['defend'] = 1 },
      redeploy: function() { new_modes['redeploy'] = 1 },
      redeployed: function() { new_modes['redeployed'] = 1 },
      declined: function() { new_modes['declined'] = 1 }
    };
    a[state_field]();
    for (var i in new_modes) {
      if (!new_modes[i]) {
        minor_modes.disable(i);
      }
    }
    for (var i in new_modes) {
      if (new_modes[i]) {
        minor_modes.enable(i);
      }
    }
  }
};

Game.direct_request_game_state = function() {
  log.d.trace('Game.direct_request_game_state');

  if (is_null(game._timer)) {
    this.request_game_state();
  } else {
    clearInterval(game._timer);
    this.request_game_state();
    game._timer = setInterval(game.request_game_state, 2000);
  }
}

Game.request_game_state = function() {
  log.d.trace('Game.request_game_state');

  if (minor_modes.have('game_started') ||
      config.force_game_state_convertion)
  {
    var h = function(resp) {
      state.store('net.getGameState', resp);
      events.exec('net.getGameState');
      game.fix_minor_mode_from_game_state();
    };
    var q = {action: 'getGameState'};
    net.send(q, h);
  } else {
    var h = function(resp) {
      state.store('net.getGameInfo', resp);
      // gameInfo is superset of gameState
      state.store('net.getGameState.gameState', resp.gameInfo);

      events.exec('net.getGameInfo');
      events.exec('net.getGameState');
      game.fix_minor_mode_from_game_state();
    };
    var q = {action: 'getGameInfo', gameId: state.get('gameId') };
    net.send(q, h);
  }
};

Game.state_monitor = {};

Game.state_monitor.start = function() {
  log.d.trace('Game.state_monitor.start');
  this.stop();

  game.request_game_state();
  game._timer = setInterval(game.request_game_state,
                            config.servert_push_interval);
};

Game.state_monitor.stop = function() {
  log.d.trace('Game.state_monitor.stop');

  clearInterval(game._timer);
  delete(game._timer);
};

Game.active_player_id = function() {
  log.d.trace('Game.active_player_id');

  var game_state = game.last_game_state();

  if (is_null(game_state)) return null;

  var is_defend = game_state.state == 'defend';
  if (!is_defend) {
    var p = game_state.players[game_state.activePlayerNum];
    return is_null(p) ? null : p.id;
  }

  var h = game_state.attacksHistory;
  return h[h.length - 1].whom;
};

Game.active_player = function() {
  log.d.trace('Game.active_player');

  var game_state = state.get('net.getGameState.gameState');
  if (is_null(game_state)) return null;

  var is_defend = game_state.state == 'defend';
  if (!is_defend) {
    return game_state.players[game_state.activePlayerNum];
  }

  var h = game_state.attacksHistory;
  var defender_id = h[h.length - 1].whom;
  for (var i in game_state.players) {
    if (game_state.players[i].id == defender_id) {
      return game_state.players[i]
    }
  }
  return null;
};

Game.active_power = function () {
  var a = game.active_player();
  return (a ? a.activePower : null)
};

Game.apply_game_state = function() {
  ui_elements.update_game_info();
  playfield.apply_game_state();
}

Game.last_game_state = function() {
  var game_state = state.get('net.getGameState.gameState',
                             'net.getGameInfo.gameInfo');
  return game_state;
};

