
var ui = {
  console: undefined,
  map: undefined,
  toolbar: undefined,
  gameinfo: undefined,

  _curr_modes: {major: null, minor: []},
  

  set_major_mode: function(new_mode) {
    log.d.info("ui -> " + new_mode +" major mode");

    var menu = $("#menu");
    var content = $("#field");
    major_modes.change_mode(menu, content, 
                            ui._curr_modes, 
                            new_mode);
    this.create_menu();
  },
  
  set_minor_mode: function(new_mode) {
    log.d.info("ui -> " + new_mode +" minor mode");

    if (minor_modes.enable(ui._curr_modes, new_mode)) {
      this.create_menu();
    }
  },
  
  disable_minor_mode: function(mode) {
    /* TODO */
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
    events.reg_h('login.success', 'tmp_save_sid', 
                 function(resp) { 
                   log.d.info('sid saved in game object');
                   game.sid = resp.sid; });

    events.reg_h('login.success', 'ui_set_logined_mode', 
                 function() { ui.set_minor_mode('logined')});
    events.reg_h('ui.refresh_menu', 'ui_create_menu', 
                 ui.create_menu);
    ui.set_major_mode('login');
    log.d.info('Game core initialized');
  }

};


