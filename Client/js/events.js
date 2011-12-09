
var events = {

  exec: function(ev_full_name, data) {
    log.d.events('event exec: ' + ev_full_name);
    if (!is_null(data)) log.d.dump(data, 'params');
    var ev = get_obj_field(this.storage, ev_full_name);
    if (is_null(ev)) { 
      var msg = 'attempt to execute undefined event: ' + 
                 ev_full_name;
      log.d.events(msg);
      return 0; 
    }
    for (var i = 0; i < ev.length; ++i) {
      log.d.events('    ' + ev[i].name);
      ev[i].fun(data);
    }
    return ev;
  },
  
  reg_h: function(ev_full_name, h_name, h_fun) {
    var ev = get_obj_field(this.storage, ev_full_name);
    if (is_null(ev)) {
      ev = set_obj_field(this.storage, ev_full_name, []);
    }   
    var i;
    for (i = 0; i < ev.length; ++i) {
      if (ev[i].name == h_name) { return 0; }        
    }
    ev.push({name: h_name, fun: h_fun});
    
    log.d.events('event handler registered: ' + 
             ev_full_name + ' -> ' + h_name);
    return ev;
  },

  del_h: function(ev_full_name, h_name) {
    var ev = get_obj_field(this.storage, ev_full_name);
    if (is_null(ev)) { return 0; }   
    var i;
    var len = ev.length;
    for (i = 0; i < len; ++i) {
      if (ev[i].name == h_name) { 
        ev.splice(i, 1);
        --i;
        --len;
      }        
    }

    log.d.events('event handler removed: ' + 
               ev_full_name + ' -> ' + h_name);
    return ev;  
  },

  delete_tree: function(ev_full_name) {
    delete_obj_field(this.storage, ev_full_name);
  },

  storage: {}
};

