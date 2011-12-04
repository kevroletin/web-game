
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
        d3.select(content).text('').node().
          appendChild(ui_forms.login.gen_form());
      },
      uninit: function() {
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

        net.send(q, function() { 
          state.delete('sid');
          events.exec('logout.success') });
      },
      uninit: function() {

      },
      in_menu: true,
    },

    register: {
      descr: 'Register',
      in_menu: true,
      init: function(content) {
        d3.select(content).text('').node().
          appendChild(ui_forms.register.gen_form());
      },
      uninit: function() {
      }
    },

    games_list: {
      descr: 'Games list',
      in_menu: true,
      init: function(content) {
        var h = function(resp) {
          d3.select(content).text('').node()
            .appendChild(ui_forms.game_list.gen_form(resp.games));
        };
        net.send({action: 'getGameList'}, h );
      }
    },

    explore_game: {
      descr: 'Explore game',
      in_menu: false,
      init: function(content, gameId) {
        var c = d3.select(content).text('');
        log.d.dump('retrive game info for gameId: ' + gameId);
        var h = function(resp) {
          var g = resp.gameInfo;
          c.append('h2')
            .text(g.gameName);
          c.append('pre')
            .text(JSON.stringify(g, null,  "  ")); 
        }
        net.send({action: 'getGameInfo', gameId: gameId}, h );
      }
    },

    users_list: {
      descr: 'Users list',
      in_menu: false,
    },

    explore_user: {
      descr: 'Explore user',
      in_menu: false,
    },

    maps_list: {
      descr: 'Maps list',
      in_menu: true,

      init: function(content) {
        var c = d3.select(content).text('');
        var h = function(resp) {
          d3.select(content).text('').node()
            .appendChild(ui_forms.maps_list.gen_form(resp.maps));
        }
        net.send({action: 'getMapList'}, h );
      }

    },

    explore_map: {
      descr: 'Explore map',
      in_menu: false,
      init: function(content, mapId) {
        var c = d3.select(content).text('');
        log.d.dump('retrive game info for gameId: ' + mapId);
        var h = function(resp) {
          var m = resp.mapInfo;
          c.append('h2')
            .text(m.mapName);
          content.appendChild(playfield.create(m));
        }
        net.send({action: 'getMapInfo', mapId: mapId}, h );
      }
    },

    play_game: {
      descr: 'Play game',
      in_menu: true,
      available_if: {
        minor_m: ['in_game']
      },
      init: function(content) {
        var c = d3.select(content).text('');

        var hg = function(resp) {
          log.d.dump(resp);
          state.store('net.getGameInfo', resp);
          c.node().
            appendChild(ui_elements.game_info(resp.gameInfo));
        };
        net.send({action: 'getGameInfo', 
                  sid: state.get('sid')}, hg );

        var hm = function(resp) {
          state.store('net.getMapInfo', resp);
          var svg = playfield.create(resp.mapInfo);
          c.node().appendChild(svg);
          playfield
            .apply_game_state(svg, state.get('net.getGameInfo').gameInfo);
        };
        net.send({action: 'getMapInfo', 
                  sid: state.get('sid')}, hm );
      }
    },
  }
  
};

var minor_modes = {

  enable: function(curr_modes, mode, params) {
    if (in_arr(mode, curr_modes.minor)) {
      return 0;
    }
    if (!_check_if_mod_available(curr_modes, mode)) {
      return 0;
    }
    if (!this.storage[mode].init(params)) {
      return 0;
    }
    curr_modes.minor.push(mode);
    return 1;
  },

  disable: function(curr_modes, mode) {
    if (!(in_arr(mode, curr_modes.minor))) {
      log.d.info('mode ' + mode + ' is not active');
      return 0;
    }
    // TODO: disable modes which are depended on this mode
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
        return 1;
      },
      uninit: function() {
        events.exec('state.clear_sid');
      }
    },
    
    in_game: {
      init: function() {
        return 1;
      },
      uninit: function() {
      }
    }
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
