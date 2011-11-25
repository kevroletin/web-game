
var ui = {
  console: undefined,
  map: undefined,
  toolbar: undefined,
  gameinfo: undefined,

  _curr_modes: {major: null, minor: []},
  

  set_major_mode: function(new_mode, params) {
    log.d.info("ui -> " + new_mode +" major mode");
    log.d.dump(params, 'params');

    var menu = $("#menu");
    var content = $("#field");
    major_modes.change_mode(menu, content, 
                            ui._curr_modes, 
                            new_mode, params);
    this.create_menu();
  },
  
  set_minor_mode: function(new_mode) {
    log.d.info("ui -> " + new_mode +" minor mode");

    if (minor_modes.enable(ui._curr_modes, new_mode)) {
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
    var menu = $("#menu");
    menu.empty().append(m);
  }

};

var protocol = {
};

var game = {

  init: function() {
    net.init();
// TODO: remove
    events.reg_h('state.store_sid', 'tmp_save_sid', 
                 function(resp) { 
                   log.d.info('sid saved into game object');
                   game.sid = resp.sid; });
    events.reg_h('state.clear_sid', 'tmp_clear_sid', 
                 function() { 
                   log.d.info('sid deleted from game object');
                   delete game.sid; });

    events.reg_h('login.success', 'ui_set_logined_mode', 
                 function() { ui.set_minor_mode('logined')});
    events.reg_h('logout.success', 'ui_set_logined_mode', 
                 function() { ui.disable_minor_mode('logined')});


    events.reg_h('ui.refresh_menu', 'ui_create_menu', 
                 ui.create_menu);
    ui.set_major_mode('login');
    log.d.info('Game core initialized');
  }

};


