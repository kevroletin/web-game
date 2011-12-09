
var ui = {
  console: undefined,
  map: undefined,
  toolbar: undefined,
  gameinfo: undefined,

  create_menu: function() {
    var modes_list = 
      major_modes.available_modes();
    var m = ui_elements.menu(modes_list);
    d3.select('div#menu').text('').node().appendChild(m);
  }

};

var protocol = {
};

var game = {

  init: function() {
    events.reg_h('login.success', 'ui_set_logined_mode', 
                 function() { minor_modes.enable('logined'); 
                       game.get_current_user_info();
                     });
    events.reg_h('user_info.success', 'ui_fix_in_game_mode', 
                 function(resp) { 
                   if (is_null(resp.activeGame)) {
                     minor_modes.disable('in_game');
                   } else {
                     minor_modes.enable('in_game');
                   }
                 });

    events.reg_h('logout.success', 'ui_disable_logined_mode', 
                 function() { minor_modes.disable('logined');
                       /* ui.disable_minor_mode('in_game'); */ });
    
    events.reg_h('game.ui_initialized', 'start main loop',
                 game.state_monitor.start);

/*    events.reg_h('ui.refresh_menu', 'ui_create_menu', 
                 ui.create_menu); */
//    major_modes.change('login');

    state.store('sid', 1);
    state.store('gameId', 1)
    game.get_current_user_info();

    major_modes.change('play_game');

    log.d.info('Game core initialized');
  }

};

game.get_current_user_info = function() {
  var q = { action: "getUserInfo",
            sid: state.get('sid') };
  var h = function(resp) {
    state.store('net.getUserInfo', resp);
    state.store('gameId', resp.activeGame);
    state.store('userId', resp.userId);
    events.exec('user_info.success', resp); 
  };
  net.send(q, h);
};

/* difference between game_info and game_state is what game 
 * state contains information which can be changed only 
 * after game being started */
game._apply_game_info = function(resp) { 
  div_game_info = d3.select('div#game_info');
  var d = d3.select('div#game_info').text('');
  ui_elements.game_info(d, resp.gameInfo);
};

game._apply_game_state = function(resp) {
 
//  var d = d3.select('div#game_info').text('');

  var svg = d3.select('svg#playfield')
      div_game_info = d3.select('div#game_info'),
      div_playfield = d3.select('div#playfield_container');

  ui_elements.update_game_info(div_game_info, resp);
  playfield.apply_game_state(svg.node(), resp); 
};

game.fix_minor_mode_from_game_state = function() {
  var getGameState = state.get(
    'net.getGameState',
    'net.getGameInfo.gameInfo'
  );
  state_field = getGameState.state;

  if (state_field == 'notStarted') {
    minor_modes.disable('game_started');
    return;
  }

  var new_modes = {
    conquer: 0,
    defend: 0,
    redeploy: 0,
    redeploed: 0,
    waiting: 0,
  };
  var active_player = 
    getGameState.players[getGameState.activePlayerNum];

  if (active_player.id !== state.get('userId')) {
    new_modes['waiting'] = 1
  } else {
    var a = {
      startMoving: function() { this.conquer() },
      conquer: function() {
        if (getGameState.attacksHistory.length == 0) {
          // TODO: select race
        }
        new_modes['conquer'] = 1

      },
      defend: function() { new_modes['defend'] = 1 },
      redeploy: function() { new_modes['redeploy'] = 1 },
      redeploed: function() { alert('not implemented') }
      
    };
    a[state_field]();
  }

  minor_modes.enable('game_started');
  for (var i in new_modes) {
    if (new_modes[i]) {
      minor_modes.enable(i);
    } else {
      minor_modes.disable(i);
    }
  }

};

game.update_game_state = function() {
//  log.d.info('---getGameState---');
  if (minor_modes.have('game_started')) {
    var h = function(resp) {
      state.store('net.getGameState', resp);
      game._apply_game_state(resp);
      events.exec('net.getGameState');
      game.fix_minor_mode_from_game_state();
    };
    var q = {action: 'getGameState'};
    net.send(q, h);    
  } else {
    var h =function(resp) {
      state.store('net.getGameInfo', resp);
      state.store('gameState', resp.gameInfo);
      game._apply_game_info(resp);
      events.exec('net.getGameInfo');
      events.exec('net.getGameState');
      game.fix_minor_mode_from_game_state();
    };
    var q = {action: 'getGameInfo'};
    net.send(q, h);
  }
};

game.state_monitor = {};

game.state_monitor.start = function() {  
  log.d.info('game main loop -> started');
  game.fix_minor_mode_from_game_state();
  game._timer = setInterval(game.update_game_state, 1000);
};


