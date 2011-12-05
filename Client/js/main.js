
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

game._apply_game_state = function(resp) {

};

/* difference between game_info and game_state is what game 
 * state contains information which can be changed only 
 * after game being started */
game._apply_game_info = function(resp) {
  div_game_info = d3.select('div#game_info');
  state.store('net.getGameInfo', resp);
  
  var d = d3.select('div#game_info').text('');
  ui_elements.game_info(d, resp.gameInfo);
  if (resp.gameInfo.state !== 'notStarted') {
    minor_modes.enable('game_started');
  };
};

game._apply_game_state = function(resp) {
  state.store('net.getGameState', resp);
  
//  var d = d3.select('div#game_info').text('');

  var svg = d3.select('svg#playfield')
      div_game_info = d3.select('div#game_info'),
      div_playfield = d3.select('div#playfield_container');

  ui_elements.update_game_info(div_game_info, resp);
  playfield.apply_game_state(svg.node(), resp); 
};

game.update_game_state = function() {
//  log.d.info('---getGameState---');
  if (minor_modes.have('game_started')) {
    var q = {action: 'getGameState'};
    net.send(q, game._apply_game_state);    
  } else {
    var q = {action: 'getGameInfo'};
    net.send(q, game._apply_game_info);
  }
};

game.state_monitor = {};

game.state_monitor.start = function() {  
  log.d.info('game main loop -> started');
  game._timer = setInterval(game.update_game_state, 1000);
};


