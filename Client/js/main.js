
var ui = {
  console: undefined,
  map: undefined,
  toolbar: undefined,
  gameinfo: undefined,

  _curr_modes: {major: null, minor: []},
  

  set_major_mode: function(new_mode, params) {
    log.d.info("ui -> " + new_mode +" major mode");
    log.d.dump(params, 'params');

    var menu = document.getElementById("menu");
    var content = document.getElementById("content");
    major_modes.change_mode(menu, content, 
                            ui._curr_modes, 
                            new_mode, params);
    this.create_menu();
  },
  
  set_minor_mode: function(new_mode, params) {
    log.d.info("ui -> " + new_mode +" minor mode");
    log.d.dump(params, 'params');

    if (minor_modes.enable(ui._curr_modes, new_mode, params)) {
      this.create_menu();
    }
  },
  
  disable_minor_mode: function(mode) {
    log.d.info("ui <- " + mode +" disable minor mode");

    if (minor_modes.disable(ui._curr_modes, mode)) {
      this.create_menu();
    }
  },
  
  create_menu: function() {
    var modes_list = 
      major_modes.available_modes(ui._curr_modes);
    var m = ui_elements.menu(modes_list);
    d3.select('div#menu').text('').node().appendChild(m);
  }

};

var protocol = {
};

var game = {

  get_current_user_info: function() {
    var q = { action: "getUserInfo",
              sid: state.get('sid') };
    var h = function(resp) {
      state.store('net.getUserInfo', resp);
      state.store('gameId', resp.activeGame);
      state.store('userId', resp.userId);
      events.exec('user_info.success', resp); 
    };
    net.send(q, h);
  },

  init: function() {
    events.reg_h('login.success', 'ui_set_logined_mode', 
                 function() { ui.set_minor_mode('logined'); 
                       game.get_current_user_info();
                     });
    events.reg_h('user_info.success', 'ui_fix_in_game_mode', 
                 function(resp) { 
                   if (is_null(resp.activeGame)) {
                     ui.disable_minor_mode('in_game');
                   } else {
                     ui.set_minor_mode('in_game');
                   }
                 });

    events.reg_h('logout.success', 'ui_disable_logined_mode', 
                 function() { ui.disable_minor_mode('logined');
                       ui.disable_minor_mode('in_game'); });

    events.reg_h('game.ui_initialized', 'start main loop',
                 game.state_monitor.start);

/*    events.reg_h('ui.refresh_menu', 'ui_create_menu', 
                 ui.create_menu); */
//    ui.set_major_mode('login');

    state.store('sid', '1');
    state.store('gameId', 1)
    game.get_current_user_info();

    ui.set_major_mode('play_game');

    log.d.info('Game core initialized');
  }

};

game._apply_game_info = function(resp) {
  div_game_info = d3.select('div#game_info');
  state.store('net.getGameInfo', resp);
  
  var d = d3.select('div#game_info').text('');
  ui_elements.game_info(d, resp.gameInfo);
};

game.update_game_state = function() {
//  log.d.info('---getGameState---');
  var q = {action: 'getGameInfo'};
  net.send(q, game._apply_game_info);
};

game.state_monitor = {};

game.state_monitor.start = function() {  
  log.d.info('game main loop -> started');
  game._timer = setInterval(game.update_game_state, 1000);
};


