
function exec(ev_full_name, data) {
  log.d.info('event exec: ' + ev_full_name);
  var ev = get_obj_field(events, ev_full_name);
  if (is_null(ev)) { return 0; }
  var i;
  for (i = 0; i < ev.length; ++i) {
    log.d.info('    ' + ev[i].name);
    ev[i].fun(data);
  }
  return ev;
}

function reg_event_h(ev_full_name, h_name, h_fun) {
  var ev = get_obj_field(events, ev_full_name);
  if (is_null(ev)) {
    ev = set_obj_field(events, ev_full_name, []);
  }   
  var i;
  for (i = 0; i < ev.length; ++i) {
    if (ev[i].name == h_name) { return 0; }        
  }
  ev.push({name: h_name, fun: h_fun});

  log.d.info('event handler registered: ' + 
             ev_full_name + ' -> ' + h_name);
  return ev;
}

function remove_event_h(ev_full_name, h_name) {
  var ev = get_obj_field(events, ev_full_name);
  if (is_null(ev)) { return 0; }   
  var i;
  var len = ev.length;
  for (i = 0; i < len; ++i) {
    if (ev[i].name == h_name) { 
      ev[i].splice(i, 1);
      --i;
      --len;
    }        
  }
  return ev;  
}

function delete_event(ev_full_name) {
  delete_obj_field(events, ev_full_name);
}

var events = {

};
