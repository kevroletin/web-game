
/* State & Net prototypes */

function net_type() {}
var Net = net_type.prototype;

function state_type() { this.storage = {} }
var State  = state_type.prototype;

/* State & Net instances */

var net = new net_type();
var state = new state_type();

/* State & Net realization */

Net.send = function(msg, on_resp, to_log, blocked) {
  if (is_null(msg.sid)) {
    msg.sid = state.get('sid');
  }
  var initial_request;
  if (config.force_game_state_convertion && !is_null(msg.action)) {
    initial_request = deep_copy(msg);
    if (msg.action == 'getGameInfo') {
      msg.action = 'getGameState';
    } else if (msg.action == 'getMapInfo') {
      msg.action = 'getMapList';
    }
  }

  var h = function(text) {
    var parsed = text ? JSON.parse(text) : null
    if (log_config.requests && to_log) {
      log.ui.info('--response--\n' + text);
    }
    if (config.force_game_state_convertion) {
      if (!is_null(parsed.gameState)) {
        CompMapper.fix_game_state(parsed.gameState);
        parsed.gameInfo = parsed.gameState;
        log.d.info('game state fixed');
      }/* else if (!is_null(parsed.gameInfo)) {
        CompMapper.fix_game_state(parsed.gameInfo);
        log.d.info('game info fixed');
      }*/ else if (!is_null(parsed.games)) {
        CompMapper.fix_game_list(parsed.games);
      }

      if (initial_request.action == 'getMapInfo') {
        for (i in parsed.maps) {
          if (parsed.maps[i].mapId == initial_request.mapId) {
            map = parsed.maps[i];
            map.regions.forEach(CompMapper._fix_region_in_place);
            parsed.mapInfo = map;
            break;
          }
        }
      }
    }
    on_resp(parsed);
  };

  var req = JSON.stringify(msg);
  if (log_config.requests && to_log) {
    log.ui.info('--request--\n' + req);
  }
  this._send_raw(req, "application/json", h, blocked);
};

Net._send_raw = function(msg, mime, callback, blocked) {
  var req = new XMLHttpRequest;
  if (mime && req.overrideMimeType) req.overrideMimeType(mime);
  req.open("POST", config.server_url, !blocked);
  req.onreadystatechange = function() {
    if (req.readyState === 4) callback(req.responseText);
  };
  req.send(msg);
}

State.store = function(key, value) {
  //    this.storage[key] = value;
  set_obj_field(this.storage, key, value);
};

State.get = function() {
  for (var i = 0; i < arguments.length; ++i) {
    var d = get_obj_field(this.storage, arguments[i]);
    if (!is_null(d)) {
      return d
    }
  }
  return null;
};

State.delete = function(key) {
  delete this.storage[key];
};

/* Misc helpers */

function deep_copy(obj) {
  return JSON.parse( JSON.stringify(obj) );
}

function make(tag) {
  var elem;
  var name = d3.ns.qualify(tag);

  if (name.local) {
    elem = document.createElementNS(name.space, name.local)
  } else {
    elem = document.createElement(name)
  }

  return d3.select(elem);
}

function is_null(obj) {
  return typeof obj == "undefined" || obj == null
}

function no_if_null(obj) {
  return is_null(obj) ? 'no' : obj;
}

function zero_if_null(obj) {
  return is_null(obj) ? 0 : obj;
}

function zero_or_one(obj) {
  return is_null(obj) ? 0 : obj ? 1 : 0;
}

function choose(obj, arr) {
  return arr[zero_or_one(obj)];
}

function yes_or_no(obj) {
  return choose(obj, ['no', 'yes']);
}

function in_arr(elem, array) {
  for (var i in array) {
    if (elem == array[i]) {
      return true;
    }
  }
  return false;
}

/* Helpers to access nested data structured */

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

/* Helpers related to game logic */

function determine_race(gameState, reg) {
  if (is_null(reg.owner)) return null;
  var p;
  for (var i in gameState.players) {
    if (gameState.players[i].id == reg.owner) {
      p = gameState.players[i]
    };
  }
  if (is_null(p)) {
      return null
  }

  if (reg.inDecline == 1) {
    if (is_null(p.declineRace)) return null;
    return p.declineRace + '_d';
  } else {
    return p.activeRace;
  };
}

