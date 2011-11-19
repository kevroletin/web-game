
var ui = {
  console: undefined,
  map: undefined,
  toolbar: undefined,
  gameinfo: undefined,

  setMode: function() { /* TODO */ },
  setRegisterMod: function() { 
    log.d.info("register");
    
    $("#field")
      .empty()
      .append(ui_forms.gen_form('register'));    
  },
  setLoginMod: function() { 
    log.d.info("ui -> login mode");

    $("#field")
      .empty()
      .append(ui_forms.gen_form('login'));
  },
  setSelectGameMode: function() { /* TODO */ }
};

var protocol = {
  _send: function(msg) { $.ajax({data: msg})},

};

var game = {

  init: function() {
    net.init();
    log.d.info('Game core initialized');
  },

  exec: function() {
    log.d.info("main loop -> started");
/* main programm loop */    
    log.d.info("main loop <- finished");
  },


};


