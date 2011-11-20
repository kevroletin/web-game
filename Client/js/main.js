
var ui = {
  console: undefined,
  map: undefined,
  toolbar: undefined,
  gameinfo: undefined,

  _curr_modes: {major: null, minor: []},
  

  setMode: function(new_mode) {
    var menu = $("#menu");
    var content = $("#field");
    this._curr_modes = 
      major_modes.change_mode(menu, content, 
                              this._curr_modes, 
                              new_mode);
  },
  setRegisterMod: function() { 
    log.d.info("register");
    
    major_modes.get('register').init($("#field"));
  },
  setLoginMod: function() { 
    log.d.info("ui -> login mode");

    major_modes.get('login').init($("#field"));
  },
  setSelectGameMode: function() { /* TODO */ }
};

var protocol = {
};

var game = {

  init: function() {
    net.init();
    ui.setMode('login');
    log.d.info('Game core initialized');
  }

};


