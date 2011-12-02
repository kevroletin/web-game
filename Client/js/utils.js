var net = {
  send: function(msg, on_resp) { 
    var h = function(text) {
      on_resp(text ? JSON.parse(text) : null);
    };
    this._send_raw(JSON.stringify(msg),
                   "application/json", 
                   h);
  },
  _send_raw: function(msg, mime, callback) {
    var req = new XMLHttpRequest;
    if (mime && req.overrideMimeType) req.overrideMimeType(mime);
    req.open("POST", server_url(), true);
    req.onreadystatechange = function() {
      if (req.readyState === 4) callback(req.responseText);
    };
    req.send(msg);
  }
};

var state = {
  store: function(key, value) {
    this.storage[key] = value;
  },
  get: function(key) {
    return this.storage[key];
  },
  delete: function(key) {
    delete this.storage[key];
  },
  storage: {}
};

function make(tag) {
  // TODO: use createElementNS instead
  var elem = document.createElement(tag);
  return d3.select(elem);
}

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
