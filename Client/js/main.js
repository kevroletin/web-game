
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
    var content = document.getElementById("field");
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
      state.store('gameId', resp.activeGame);
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

/*    events.reg_h('ui.refresh_menu', 'ui_create_menu', 
                 ui.create_menu); */
    ui.set_major_mode('login');
    log.d.info('Game core initialized');
  }

};


