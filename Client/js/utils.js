
var net = {

  init: function () {
    $.ajaxSetup({url: server_url(),
                 type: 'POST',
                 processData: 0});
  },
  send: function(msg, on_resp) { 
    $.ajax({url: server_url(),
            type: 'POST',
            processData: 0,
            crossDomain: true,
            data: JSON.stringify(msg),
            complete: this._on_resp_wrapper(on_resp)});
  },
  _on_resp_wrapper: function(fun) {
    return function(data, textStatus, jqXHR) {
      /* TODO: process server errors 
         if (data.status != 200 ) {
           log.d.err('server is down');
           log.ui.err('server is down');
         }
      */
      //var text = data.;
      //JSON.parse(str)
      return fun(JSON.parse(data.responseText));
    };
  }

};

function is_null(obj) {
  return typeof obj == "undefined" || obj == null
}

function get_obj_field(obj, field_name) {
  var f = field_name.split('.');
  var t = obj;
  var i;
  for (i = 0; i < f.length && !is_null(t); ++i) {
    t = t[f[i]];
  }
  return t;
}

function set_obj_field(obj, field_name, value) {
  var f = field_name.split('.');
  var t = obj;
  var i;
  for (i = 0; i < f.length - 1 && !is_null(t); ++i) {
    if (is_null(t[f[i]])) { 
      t[f[i]] = {};
    }
    t = t[f[i]];
  }
  t[f[f.length - 1]] = value;
  return value;
}

function delete_obj_field(obj, field_name) {
  var f = field_name.split('.');
  var t = obj;
  var i;
  for (i = 0; i < f.length - 1 && !is_null(t); ++i) {
    if (is_null(t[f[i]])) { return 0; }
    t = t[f[i]];
  }
  delete t[f[f.length - 1]];
  return t;
}

function in_arr(elem, array) {
  for (var i in array) {
    if (elem == array[i]) {
      return true;
    }
  }
  return false;
}
