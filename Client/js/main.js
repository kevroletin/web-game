
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
    reg_event_h('login.success', 'store_sid',
                function(data) { 
                  log.d.info('sid: ' + data.sid);
                });
  },
  setSelectGameMode: function() { /* TODO */ }
};

var protocol = {
};

var game = {

  init: function() {
    net.init();
    log.d.info('Game core initialized');
  }

};


