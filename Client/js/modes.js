
var major_modes = {

  change_mode: function(menu, content, curr_modes, new_m, params) {
    /* TODO: raise error if we want to go into major mode which
       can not be used with active minor mode */
    /* TODO: disable needed minor modes */

    if (!is_null(curr_modes.major) &&
        !is_null(this.storage[curr_modes.major].uninit)) {
      this.storage[curr_modes.major].uninit();
    }
    this.storage[new_m].init(content, params);
    curr_modes.major = new_m;
    return curr_modes;
  },
  
  available_modes: function(curr_modes) {
    var res = [];
    for (var i in this.storage) {
      var m = this.storage[i];
      if (!(is_null(m.in_menu) || !m.in_menu) &&
           _check_if_mod_available(curr_modes, m))
      {
        res.push({name: i, obj: this.storage[i]});
      }
    }  
    return res;
  },

  get: function(mod_name) { 
    return this.storage[mod_name]; 
  },

  storage: {

    login: {
      descr: 'Login',
      in_menu: true,
      init: function(content) {
        content.empty()
          .append(ui_forms.login.gen_form());

        var h = function(data) { 
          events.exec('state.store_sid', data);
        };
        events.reg_h('login.success', 'store_sid', h);
      },
      uninit: function() {
        events.del_h('login.success', 'store_sid');
      }
    },

    logout: {
      descr: 'Logout',
      available_if: {
        minor_m: ['logined'],
      },
      init: function(content) {
        var q = { action: "logout",
                  sid: game.sid };

        net.send(q, function() { events.exec('logout.success') });
      },
      uninit: function() {

      },
      in_menu: true,
    },

    register: {
      descr: 'Register',
      in_menu: true,
      init: function(content) {
        content.empty()
          .append(ui_forms.register.gen_form());
      },
      uninit: function() {
      }
    },

    games_list: {
      descr: 'Games list',
      in_menu: true,
      init: function(content) {
        var h = function(resp) {
          content.empty();
          var f = ui_forms.game_list.gen_form(resp.games);
          content.append(f);
        };
        net.send({action: 'getGameList'}, h );
      }
    },

    explore_game: {
      descr: 'Explore game',
      in_menu: false,
      init: function(content, gameId) {
        content.empty();
        log.d.dump('retrive game info for gameId: ' + gameId);
        var h = function(resp) {
          var g = resp.gameInfo;
          content.append('<pre>' + JSON.stringify(g, null,  "  ") + 
                         '</pre>')
          content.append('<h2>' + g.gameName + '</h2>');
          content.append('<h4>Players:</h4>');
          for (var i = 0; i < g.players.length; ++i) {
            var d = $('<div id="player_descr">');
            var p = g.players[i];
            d.textContent = JSON.stringify(p);
            content.append(d);
          }
        }
        net.send({action: 'getGameInfo', gameId: gameId}, h );
      }
    },

    users_list: {
      descr: 'Users list',
      in_menu: true,
    },

    explore_user: {
      descr: 'Explore user',
      in_menu: false,
    },

    maps_list: {
      descr: 'Maps list',
      in_menu: true,

      init: function(content) {
        content.empty();
        var h = function(resp) {
          /* TODO: rework and move to another module */
          var t = $('<table id="gamesList">');
          if (resp.maps.length == 0) { return 0; }
          
          var tr = $('<tr>');
          for (var i in resp.maps[0]) {
            tr.append($('<th>' + i + '</th>'));
          }
          t.append(tr);

          for (var i in resp.maps) {
            var tr = $('<tr>');
            for (var prop in resp.maps[i]) {
              tr.append($('<td>' + resp.maps[i][prop] +
                          '</td>'));
            }
            t.append(tr);
          }
          content.append(t);
        }
        net.send({action: 'getMapList'}, h );
      }

    },

    explore_map: {
      descr: 'Explore map',
      in_menu: false
    }
  }
  
};

var minor_modes = {

  enable: function(curr_modes, mode) {
    if (in_arr(mode, curr_modes.minor)) {
      return 0;
    }
    if (!_check_if_mod_available(curr_modes, mode)) {
      return 0;
    }
    this.storage[mode].init();
    curr_modes.minor.push(mode);
    return 1;
  },

  disable: function(curr_modes, mode) {
    if (!(in_arr(mode, curr_modes.minor))) {
      log.d.info('mode ' + mode + ' is not active');
      return 0;
    }
    var len = curr_modes.minor.length;
    for (var i = 0; i < len; ++i) {
      if (curr_modes.minor[i] == mode) {
        curr_modes.minor.splice(i, 1);
        --i;
        --len;
      }
    }
    if (!is_null(this.storage[mode].uninit)) {
      this.storage[mode].uninit();
    }
    return 1;
  },

  storage: {
    logined: {
      init: function() { 
      },
      uninit: function() {
        events.exec('state.clear_sid');
      }
    },
  }
};

function _check_if_mod_available(curr_modes, m_obj) {
  if (is_null(m_obj.available_if)) {
    return true;
  }
  if (!is_null(m_obj.available_if.major_m)) {
    var c = m_obj.available_if.major_m;
      var ok = 0;
    for (var i = 0; i < c.length && !ok; ++i) {
        ok = curr_modes.major == c[i]
    }
    if (!ok) { return false; }
  }
  if (!is_null(m_obj.available_if.not_major_m)) { 
    var c = m_obj.available_if.major_m;
    for (var i = 0; i < c.length && !ok; ++i) {
      if (curr_modes.major == c[i]) {
        return false;
      }
    }
  }
  if (!is_null(m_obj.available_if.minor_m)) {
    var c = m_obj.available_if.minor_m;
    var ok = 0;
    for (var i = 0; i < c.length && !ok; ++i) {
      ok = in_arr(c[i], curr_modes.minor)
    }
    if (!ok) { return false; }
  }
  if (!is_null(m_obj.available_if.not_minor_m)) {
    var c = m_obj.available_if.not_minor_m;
    for (var i = 0; i < c.length && !ok; ++i) {
      if (in_arr(c[i], curr_modes.minor)) {
        return false;
      }
    }
  }
  
  return true;
}
