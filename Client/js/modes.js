
var curr_modes = {major: null, minor: []};

var major_modes = {

  change: function(new_m, params) {
    log.d.info("|new major mode| -> " + new_m);
    log.d.dump(params, 'params');

    /* TODO: raise error if we want to go into major mode which
       can not be used with active minor mode or
       disable needed minor modes */
    var menu = document.getElementById("menu");
    var content = document.getElementById("content");

    if (!is_null(curr_modes.major) &&
        !is_null(this.storage[curr_modes.major].uninit)) {
      this.storage[curr_modes.major].uninit();
    }
    this.storage[new_m].init(content, params);
    curr_modes.major = new_m;

    ui.create_menu();
  },
  
  available_modes: function() {
    var res = [];
    for (var i in this.storage) {
      var m = this.storage[i];
      if (!(is_null(m.in_menu) || !m.in_menu) &&
           _check_if_mod_available(m))
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
            div_game_info = c.append('div')
                             .attr('id', 'game_info');
            div_playfield = c.append('div')
                             .attr('id', 'playfield_container')
            ans_cnt = 0;

        var hg = function(resp) {
          state.store('net.getGameInfo', resp);
          ui_elements.game_info(div_game_info, resp.gameInfo);
          if (++ans_cnt == 2) {
            events.exec('game.ui_initialized');
          }
        };
        net.send({action: 'getGameInfo', 
                  sid: state.get('sid')}, hg );

        var hm = function(resp) {
          state.store('net.getMapInfo', resp);
          var svg = div_playfield.append('svg');
          playfield.create(svg, resp.mapInfo);
          playfield.apply_game_state(
              svg.node(), state.get('net.getGameInfo').gameInfo);
          if (++ans_cnt == 2) {
            events.exec('game.ui_initialized');
          }
        };
        net.send({action: 'getMapInfo', 
                  sid: state.get('sid')}, hm );

      }
    },
  }
  
};

var minor_modes = {

  storage: {

    logined: {
      init: function() { 
        return 1;
      },
      uninit: function() {
        events.exec('state');
      }
    },
    
    in_game: {
      available_if: {
        minor_m: ['logined']
      },
      init: function() {
        return 1;
      },
      uninit: function() {
      }
    },

    game_started: {
      available_if: {
        minor_m: ['in_game']
      },
      init: function() {
        var tok = state.get(
          'net.getGameState.visibleTokenBadges',
          'net.getGameInfo.gameInfo.visibleTokenBadges'
        );

        if (is_null(tok)) {
          alert('visibleTokenBadges is null');
        }

        d3.select('div#game_info')
          .append('div')
          .attr('id', 'tokens_packs')
          .selectAll('div.tokens_pack')
          .data(tok)
        .enter()
          .append('div')
          .each(function(d, i) {

            var t = d3.select(this)
              .attr('class', 'tokens_pack');
            t.append('div').text(d.raceName);
            t.append('div').text(d.specialPowerName);
            t.append('div').text(d.bonusMoney);
          });

        return 0;
      },
      uninit: function() {}
    },

    conquer: {
      available_if: {
        minor_m: ['in_game'],
        not_minor_m: ['redeploy', 'defend', 'waiting']
      },
      init : function() {
        minor_modes.enable('select_race');
        minor_modes.enable('decline');
        
        var on_resp = function(resp) {
          alert(JSON.stringify(resp, null, ' '));
        };
        
        var h = function(reg_i) {
          net.send({"action":"conquer","regionId": reg_i}, 
                   on_resp);
        };
        events.reg_h('game.region.click', 'conquer_on_click', h);

        return 0;
      },
      uninit: function() {
        minor_modes.disable('select_race');
        minor_modes.sicable('decline');
      }
    },

    select_race: {
      available_if: {
        minor_m: ['conquer'],
      },
      init : function() {
        var on_resp = function(resp) {
          // TODO:
          alert(resp.result);
        };
        var h = function(d, i) {
          net.send({"position": d.position,
                    "action":"selectRace"}, 
                   on_resp);
          d3.event.preventDefault();
        };

        d3.selectAll('div.tokens_pack')
          .append('form')
            .classed('select_race', 1)
            .on('submit', h)
          .append('input')
            .attr('name', 'ok')
            .attr('type', 'submit')
            .attr('value', 'select');
        return 0;
      },
      uninit: function() {}
    },

    decline: {
      available_if: {
        minor_m: ['conquer'],
      },
      init : function() {
        var on_resp = function(resp) {
          // TODO:
          if (resp.result == 'eq') {
          } else {
          }
          alert(resp.result);
        };

        var h = function() {
          net.send({action: 'decline'}, on_resp);
          d3.event.preventDefault();
        };

        d3.select('div.active_player')
          .append('form')
            .attr('id', 'go_decline')
            .on('submit', h)
          .append('input')
            .attr('name', 'ok')
            .attr('type', 'submit')
            .attr('value', 'decline');
        return 0;
      },
      uninit: function() {
        d3.select('form#go_decline').remove();
      }
    },

    redeploy: {
      available_if: {
        minor_m: ['in_game'],
        not_minor_m: ['attack', 'defend', 'waiting']
      },
      init : function() {
        alert('not implemented');
        return 0;
      },
      uninit: function() {}
    },

    defend: {
      available_if: {
        minor_m: ['in_game'],
        not_minor_m: ['attack', 'redeploy', 'waiting']
      },
      init : function() {
        alert('not implemented');
        return 0;
      },
      uninit: function() {}
    },

    waiting: {
      available_if: {
        minor_m: ['in_game'],
        not_minor_m: ['attack', 'redeploy', 'defend']
      },
      init : function() {
        return 0;
      },
      uninit: function() {}
    }
  }
};

minor_modes.have = function(mode) {
  return in_arr(mode, curr_modes.minor);
}; 

minor_modes.enable = function(mode, params) {
  if (in_arr(mode, curr_modes.minor)) {
    log.d.warn('mode ' + mode + ' already enabled');
    return 0;
  }

  if (is_null(this.storage[mode])) {
    log.d.err('bad mode: ' + mode );
  }

  log.d.info("|minor mode| -> " + mode);
  log.d.dump(params, 'params');

  if (!_check_if_mod_available(mode)) {
    log.d.warn('mode is not avaible');
    return 0;
  }

  curr_modes.minor.push(mode);

  if (!this.storage[mode].init(params)) {
    return 0;
  }

  ui.create_menu();

  return 1;
};

minor_modes.disable = function(mode) {

  if (!(in_arr(mode, curr_modes.minor))) {
    log.d.warn('mode ' + mode + ' is not active');
    return 0;
  }

  log.d.info("|minor mode| -- " + mode);

  var len = curr_modes.minor.length;
  for (var i = 0; i < len; ++i) {
    var mi_name = curr_modes.minor[i];
    if (mi_name == mode) {
      curr_modes.minor.splice(i, 1);
      --i;
      --len;
    }
  }

  var len = curr_modes.minor.length;
  for (var i = 0; i < len; ++i) {
    var mi_name = curr_modes.minor[i];
    var mi = minor_modes.storage[mi_name];
    if (!is_null(mi.available_if) &&
        !is_null(mi.available_if.minor_m))
    {
      if (in_arr(mode, mi.available_if.minor_m)) {
        log.d.info('depended mode disabled: ' + mi_name);
        minor_modes.disable(mi_name);
        i = 0;
        len = curr_modes.minor.length;
      }
    }
  }

  if (!is_null(this.storage[mode].uninit)) {
    this.storage[mode].uninit();
  }

  ui.create_menu();

  return 1;
};

function _check_if_mod_available(m_obj) {
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
