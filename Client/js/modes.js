
/* Stores current modes */
var curr_modes = {major: null, minor: []};

/* Modes prototypes */

function major_modes_type() {
  this.storage = {};
};

var major_modes = new major_modes_type();
var Major_Modes = major_modes_type.prototype;

function minor_modes_type() {
  this.storage = {}
}

var minor_modes = new minor_modes_type();
var Minor_Modes = minor_modes_type.prototype;

// Common for minor in major modes
function _check_if_mod_available(m_obj, only_dependencies) {
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
  if (!is_null(m_obj.available_if.minor_m)) {
    var c = m_obj.available_if.minor_m;
    var ok = 0;
    for (var i = 0; i < c.length && !ok; ++i) {
      ok = in_arr(c[i], curr_modes.minor)
    }
    if (!ok) { return false; }
  }

  if (!is_null(m_obj.available_if.not_major_m)) {
    var c = m_obj.available_if.major_m;
    for (var i = 0; i < c.length; ++i) {
      if (curr_modes.major == c[i]) {
        return false;
      }
    }
  }

  if (zero_or_one(only_dependencies)) {
    return true;
  }

  if (!is_null(m_obj.available_if.not_minor_m)) {
    var c = m_obj.available_if.not_minor_m;
    for (var i = 0; i < c.length; ++i) {
      if (in_arr(c[i], curr_modes.minor)) {
        return false;
      }
    }
  }

  return true;
}

/* Major modes */

Major_Modes.change = function(new_m, params) {
  log.d.info("|new major mode| -> " + new_m);
  log.d.dump(params, 'params');

  curr_modes.major = new_m;

  /* disable minor mode with can't be used with new major mode */
  var len = curr_modes.minor.length;
  for (var i = 0; i < len; ++i) {
    var mi_name = curr_modes.minor[i];
    var mi = minor_modes.storage[mi_name];
    if (!is_null(mi.available_if)) {
      if (!is_null(mi.available_if.major_m) &&
          !in_arr(new_m, mi.available_if.major_m) ||
          !is_null(mi.available_if.not_major_m) &&
          in_arr(new_m, mi.available_if.not_major_m))
      {
        log.d.info('conflicting mode disabled: ' + mi_name);
        minor_modes.disable(mi_name);
        i = 0;
        len = curr_modes.minor.length;
      }
    }
  }

  var menu = document.getElementById("menu");
  var content = document.getElementById("content");

  if (!is_null(curr_modes.major) &&
      !is_null(this.storage[curr_modes.major].uninit)) {
    this.storage[curr_modes.major].uninit();
  }
  this.storage[new_m].init(content, params);

  ui.create_menu();
  log.ui.modes(curr_modes);
};

Major_Modes.available_modes = function() {
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
};

Major_Modes.get = function(mod_name) {
  return this.storage[mod_name];
};

major_modes.storage.login = {
  descr: 'Login',
  in_menu: true,
  init: function(content) {
    d3.select(content).text('').node().
      appendChild(ui_forms.login.gen_form());
  },
  uninit: function() {
  }
};

major_modes.storage.logout = {
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
};

major_modes.storage.register = {
  descr: 'Register',
  in_menu: true,
  init: function(content) {
    var form = ui_forms.register.gen_form();
    d3.select(content).text('').node().
      appendChild(form);
    if (config.autologin == 1) {
      form.elements['autologin'].checked = true;
    }
  },
  uninit: function() {
  }
};

major_modes.storage.games_list = {
  descr: 'Games list',
  in_menu: true,
  init: function(content) {
    var h = function(resp) {
      d3.select(content).text('').node()
        .appendChild(ui_forms.game_list.gen_form(resp.games));
    };
    net.send({action: 'getGameList'}, h );
  }
};

major_modes.storage.games_new = {
  available_if: {
    minor_m: ['logined'],
    not_minor_m: ['in_game']
  },
  descr: 'New game',
  in_menu: true,
  init: function(content) {
    var c = d3.select(content);
    c.text('');
    c.append('h2').text('Create new game');
    var f = c.append('form')
      .attr('onSubmit', 'return false;');
    f.on('submit', function(d) {
      var h = function(resp) {
        if (errors.descr_resp(resp) == 'ok') {
          game.direct_request_game_state();
          major_modes.change('play_game');
        }
      };
      var q = { action: 'createGame',
                gameDescr: f.node()['gameDescr'].value,
                gameName: f.node()['gameName'].value,
                mapId: f.node()['mapId'].value };
      net.send(q, h, 1);
      return false;
    });

    var table = f.append('table');
    var create_table = function(d) {
      d.forEach(function(t) {
        var tr = table.append('tr');
        tr.append('td').text(t[0]);
        t[1](tr.append('td'));
      })
    };
    create_table([
      ['Game name',
       function(f) {
         f.append('input')
           .attr('type', 'textfield')
           .attr('name', 'gameName');
       }],
      ['Map',
       function(f) {
         var h = function(resp) {
           var sel = f.append('select')
             .attr('name', 'mapId');
           resp.maps.forEach(function(map) {
             sel.append('option')
               .attr('value', map.mapId)
               .text(map.mapName);
           });
         };
         net.send({action: 'getMapList'}, h);
       }],
      ['Description',
       function(f) {
         f.append('textarea')
           .attr('name', 'gameDescr')
       }],
      ['',
       function(f) {
         f.append('input')
           .attr('type', 'submit')
           .attr('value', 'ok');
       }]
    ]);
  }
};

major_modes.storage.explore_game = {
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
};

major_modes.storage.users_list = {
  descr: 'Users list',
  in_menu: false,
};

major_modes.storage.explore_user = {
  descr: 'Explore user',
  in_menu: false,
};

major_modes.storage.maps_list = {
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

};

major_modes.storage.explore_map = {
  descr: 'Explore map',
  in_menu: false,
  init: function(content, mapId) {
    var c = d3.select(content).text('');
    var draw_map = function (map) {
      log.d.pretty(map);
      c.append('h2').text(map.mapName);
      var svg = c.append('div').append('svg:svg');
      content.appendChild(playfield.create(svg, map));
    };

    if (features.getMapInfo) {
      log.d.dump('retrive map info for mapId: ' + mapId);
      var h = function(resp) { draw_map(resp.mapInfo) };
      net.send({action: 'getMapInfo', mapId: mapId}, h );
    } else {
      log.d.dump('retrive map info from maps list for mapId: ' + mapId);
      var h = function(resp) {
        for (var i in resp.maps) {
          if (resp.maps[i].mapId == mapId) {
            return draw_map(resp.maps[i])
          }
        }
        log.d.err('attempt to find map description in maps list failed');
      }
      net.send({action: 'getMapList', mapId: mapId}, h );
    }
  }
};

major_modes.storage.play_game = {
  descr: 'Play game',
  in_menu: true,
  available_if: {
    minor_m: ['in_game']
  },
  _create_ui: function() {
    var c = d3.select('div#content').text('');
    div_game_info = c.append('div')
      .attr('id', 'game_info');
    c.append('div')
      .attr('id', 'actions');
    var div_playfield = c.append('div')
      .attr('id', 'playfield_container')
    ans_cnt = 0,
    svg = null;

    var hg = function(resp) {
      state.store('net.getGameInfo', resp);
      state.store('net.getGameState', resp.gameInfo);

      ui_elements.game_info(resp.gameInfo, div_game_info);
      if (++ans_cnt == 2) {
        playfield.apply_game_state(
          state.get('net.getGameInfo').gameInfo);
        events.exec('game.ui_initialized');
      }
    };
    net.send({action: 'getGameInfo',
              sid: state.get('sid')}, hg );

    var hm = function(resp) {
      state.store('net.getMapInfo', resp);
      svg = div_playfield.append('svg:svg');
      playfield.create(svg, resp.mapInfo);

      if (++ans_cnt == 2) {
        playfield.apply_game_state(
          state.get('net.getGameInfo').gameInfo);
        events.exec('game.ui_initialized');
      }
    };
    net.send({action: 'getMapInfo',
              sid: state.get('sid')}, hm );

  },
  _watch_game_info_updates: function() {
    var h = function() {
      var data = state.get('net.getGameInfo');
      var div = d3.select('div#game_info').text('');
      ui_elements.game_info(data.gameInfo, div);
    };
    events.reg_h('net.getGameInfo',
                 'major_modes.play_game->net.getGameInfo',
                 h);
  },
  init: function() {
    this._create_ui();
    this._watch_game_info_updates();
  },
  uninit: function() {
    events.del_h('net.getGameInfo',
                 'major_modes.play_game->net.getGameInfo');
  }
};


/* Minor modes */

minor_modes.storage.logined = {
  init: function() {
    return 1;
  },
  uninit: function() {
    events.exec('state');
  }
};

minor_modes.storage.in_game = {
  available_if: {
    minor_m: ['logined']
  },
  init: function() { return 1;  },
  uninit: function() {  }
};

minor_modes.storage.game_started = {
  available_if: {
    major_m: ['play_game'],
    minor_m: ['in_game'],
  },
  _create_ui: function() {
    log.d.trace('minor_modes.storage.game_started._create_ui');

    ui_elements._update_token_badges();
  },
  _watch_game_state_updates: function() {
    var h = function() {
      var game_state = state.get('net.getGameState.gameState');
      ui_elements.update_game_info(game_state);
      playfield.apply_game_state(game_state);
    };
    events.reg_h('net.getGameState',
                 'minor_modes.game_started->net.getGameState',
                 h);
  },
  init: function() {
    this._create_ui();
    this._watch_game_state_updates();
    return 0;
  },
  uninit: function() {
    events.del_h('minor_modes.game_started->net.getGameState');
  }
}

minor_modes.storage.conquer = {
  available_if: {
    major_m: ['play_game'],
    minor_m: ['in_game'],
    not_minor_m: ['redeploy', 'defend', 'waiting']
  },
  _watch_map_onclick: function() {
    var on_resp = function(resp) {
      game.direct_request_game_state();
      if (errors.descr_resp(resp) == 'ok' && !is_null(resp.dice)) {
        alert('dice: ' + resp.dice);
      }
    };

    var h = function(reg_i) {
      net.send({"action":"conquer","regionId": reg_i + 1},
               on_resp);
    };
    events.reg_h('game.region.click',
                 'minor_modes.conquer->game.region.click',
                 h);
  },
  _prepare_ui: function() {
    var h = function() {
      d3.event.preventDefault();
      minor_modes.force('redeploy');
    };
    d3.select('div#actions')
      .append('form')
      .attr('id', 'begin_redeploy')
      .on('submit', h)
      .append('input')
      .attr('type', 'submit')
      .attr('value', 'redeploy');
  },
  init : function() {
    this._watch_map_onclick();
    this._prepare_ui();

    return 0;
  },
  uninit: function() {
    events.del_h('game.region.click',
                 'minor_modes.conquer->game.region.click');
    d3.select('form#begin_redeploy').remove();

    minor_modes.disable('select_race');
    minor_modes.disable('decline');
  }
};

minor_modes.storage.select_race = {
  available_if: {
    major_m: ['play_game'],
    minor_m: ['conquer'],
  },
  init : function() {
    var on_resp = function(resp) {
      game.direct_request_game_state();
      errors.descr_resp(resp);
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
  uninit: function() {
    d3.selectAll('form.select_race').remove();
  }
};

minor_modes.storage.decline = {
  available_if: {
    minor_m: ['conquer'],
  },
  init : function() {
    var on_resp = function(resp) {
      // TODO:
      if (resp.result !== 'ok') {
        alert(resp.result);
      }
      game.direct_request_game_state();
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
};

minor_modes.storage.redeploy = {
  available_if: {
    minor_m: ['in_game'],
    not_minor_m: ['decline', 'select_race',
                  'conquer', 'defend', 'waiting']
  },
  _prepare_redeploy_data: function() {
    var regions = state.get('net.getGameState.gameState.regions');
    var res = [];
    for (var i in regions) {
      var r = regions[i];
      if (r.owner == state.get('userId') && r.tokensNum > 0 &&
          !r.inDecline)
      {
        res.push({tokensNum: r.tokensNum,
                  regionId: Number(i) + 1 });
      }
    }
    return res;
  },
  _send_redeploy: function() {
    var data = this._prepare_redeploy_data();
    var h = function(resp) {
      if (resp.result !== 'ok') {
        minor_modes.force('redeploy');
        alert(resp.result);
      } else {
        minor_modes.force('redeployed');
      }
    };
    net.send({"regions": data, action: "redeploy"}, h, 1);
  },
  _prepare_ui: function() {
    var submit_h = function() {
      d3.event.preventDefault();
      minor_modes.storage.redeploy._send_redeploy();
    };
    var undo_h = function() {
      game.direct_request_game_state();
    };
    var act = d3.select('div#actions');
    act.append('form')
      .attr('onsubmit', 'return false;')
      .attr('id', 'finish_redeploy')
      .on('submit', submit_h)
      .append('input')
      .attr('type', 'submit')
      .attr('value', 'submit');
    act.append('form')
      .attr('onsubmit', 'return false;')
      .attr('id', 'undo_redeploy')
      .on('submit', undo_h)
      .append('input')
      .attr('type', 'submit')
      .attr('value', 'undo');
  },
  _prepare_map_actions: function() {
    var plus = function(reg_i) {
      var regions = state.get('net.getGameState.gameState.regions');
      var player = game.active_player();

      if (regions[reg_i].owner !== player.id || regions[reg_i].inDecline) {
        return;
      }

      if (!player.tokensInHand) {
        alert('no tokens in hand')
      } else {
        --player.tokensInHand;
        ++regions[reg_i].tokensNum;
        events.exec('net.getGameState');
      }
    };
    events.reg_h('game.region.click',
                 'minor_modes.redeploy->game.region.click',
                 plus);
    var minus = function(reg_i) {
      var regions = state.get('net.getGameState.gameState.regions');
      var player = game.active_player();

      if (regions[reg_i].owner !== player.id || regions[reg_i].inDecline) {
        return;
      }

      if (!regions[reg_i].tokensNum) {
        alert('no tokens on region')
      } else {
        ++player.tokensInHand;
        --regions[reg_i].tokensNum;
        events.exec('net.getGameState');
      }
    };
    events.reg_h('game.region.image.click',
                 'minor_modes.redeploy->game.region.image.click',
                 minus);
  },
  init : function() {
    this._prepare_ui();
    this._prepare_map_actions();
    return 0;
  },
  uninit: function() {
    events.del_h('game.region.click',
                 'minor_modes.redeploy->game.region.click');
    events.del_h('game.region.image.click',
                 'minor_modes.redeploy->game.region.image.click');

    d3.select('form#finish_redeploy').remove();
    d3.select('form#undo_redeploy').remove();
  }
};

minor_modes.storage.redeployed = {
  available_if: {
    major_m: ['play_game'],
    not_minor_m: ['conquer', 'redeploy', 'waiting']
  },
  _finish_turn: function() {
    var on_resp_finish = function(resp) {
      if (resp.result == 'ok')  {
        game.direct_request_game_state();
      } else {
        alert(resp.result);
      }
    };
    net.send({action: 'finishTurn'}, on_resp_finish, 1)
  },
  _ui_form_finish_turn: function() {
    d3.select('div#actions')
      .append('form')
      .attr('id', 'finish_turn')
      .attr('onsubmit', 'return false;')
      .on('submit', minor_modes.storage.redeployed._finish_turn)
      .append('input')
      .attr('type', 'submit')
      .attr('value', 'finish_turn');
  },
  _ui_for_diplomat: function() {
    var on_resp_select = function(resp) {
      if (resp.result == 'ok') {
        minor_modes.storage.redeployed._finish_turn();
      } else {
        alert(resp.result);
      }
    };
    var h_select = function() {
      var friend_id = this.elements['friend_id'].value;
      net.send({action: 'selectFriend', userId: friend_id}, on_resp_select, 1)
    };
    var friend_form = d3.select('div#actions')
      .append('form')
      .attr('id', 'form_friends')
      .attr('onsubmit', 'return false;')
      .on('submit', h_select);
    var players = state.get('net.getGameInfo.gameInfo.players');
    log.d.pretty(players);
    friend_form
      .append('select')
      .attr('id', 'select_friend')
      .attr('name', 'friend_id')
      .selectAll('option')
      .data(players)
        .enter()
        .append('option')
        .attr('value', function(d) { return d.id })
        .text(function(d) { return d.name });
    friend_form
      .append('input')
      .attr('type', 'submit')
      .attr('value', 'select_friend');
  },
  _ui_for_stout: function() {
    var on_resp = function(resp) {
      if (resp.result == 'ok') {
        minor_modes.storage.redeployed._finish_turn();
      } else {
        alert(resp.result)
      }
    };
    var h = function() {
      net.send({action: 'decline'}, on_resp)
    };

    d3.select('div#actions')
      .append('form')
      .attr('id', 'form_stout')
      .attr('onsubmit', 'return false;')
      .on('submit', h)
      .append('input')
      .attr('type', 'submit')
      .attr('value', 'decline');
  },
  init : function() {

    if (game.active_player().activePower == 'diplomat') {
      this._ui_form_finish_turn();
      this._ui_for_diplomat();
    } else if (game.active_player().activePower == 'stout') {
      this._ui_form_finish_turn();
      this._ui_for_stout();
    } else {
      this._finish_turn();
    }

    return 0;
  },
  uninit: function() {
    d3.select('form#finish_turn').remove();
    d3.select('form#form_friends').remove();
    d3.select('form#form_stout').remove();
  }
};

minor_modes.storage.declined = {
  available_if: {
    minor_m: ['in_game'],
    not_minor_m: ['conquer', 'redeploy', 'waiting']
  },
  init : function() {
    var on_resp = function(resp) {
      if (resp.result == 'ok')  {
        game.direct_request_game_state();
//        minor_modes.force('waiting');
      } else {
        alert(resp.result);
      }
    };

    if (1) {
      net.send({action: 'finishTurn'}, on_resp, 1)
      return 0;
    }
    // This button is needed to some races which can do additional
    // actions before finishTurn

    var h = function() {
      d3.event.preventDefault();
      net.send({action: 'finishTurn'}, on_resp, 1)
    };
    d3.select('div#actions')
      .append('form')
      .attr('id', 'finish_turn')
      .on('submit', h)
      .append('input')
      .attr('type', 'submit')
      .attr('value', 'finish_turn');
    return 0;
  },
  uninit: function() {
    d3.select('form#finish_turn').remove();
  }
};

minor_modes.storage.defend = {
  available_if: {
    minor_m: ['in_game'],
    not_minor_m: ['conquer', 'redeploy', 'waiting']
  },
  _prepare_defend_data: function() {
    var regions = state.get('net.getGameState.gameState.regions');
    var regions_old = minor_modes.storage.defend.__old_regions__;
    var res = [];
    for (var i in regions) {
      var r_new = regions[i];
      var r_old = regions_old[i];
      if (r_new.owner == state.get('userId') &&
          r_new.tokensNum - r_old.tokensNum > 0 &&
          !r_new.inDecline)
      {
        res.push({tokensNum: r_new.tokensNum - r_old.tokensNum,
                  regionId: Number(i) + 1 });
      }
    }
    return res;
  },
  _send_defend: function() {
    var data = this._prepare_defend_data();
    var h = function(resp) {
      if (resp.result == 'ok') {
        minor_modes.force('waiting');
      } else {
        minor_modes.force('defend');
        alert(resp.result);
      }
    };
    net.send({"regions": data, action: "defend"}, h, 1);
  },
  _prepare_ui: function() {
    var submit_h = function() {
      d3.event.preventDefault();
      minor_modes.storage.defend._send_defend();
    };
    var undo_h = function() {
      game.direct_request_game_state();
    };
    var act = d3.select('div#actions');
    act.append('form')
      .attr('onsubmit', 'return false;')
      .attr('id', 'finish_defend')
      .on('submit', submit_h)
      .append('input')
      .attr('type', 'submit')
      .attr('value', 'submit');
    act.append('form')
      .attr('onsubmit', 'return false;')
      .attr('id', 'undo_defend')
      .on('submit', undo_h)
      .append('input')
      .attr('type', 'submit')
      .attr('value', 'undo');
  },
  _prepare_map_actions: function() {
    var plus = function(reg_i) {
      var regions = state.get('net.getGameState.gameState.regions');
      var player = game.active_player();

      if (regions[reg_i].owner !== player.id || regions[reg_i].inDecline) {
        return;
      }

      if (!player.tokensInHand) {
        alert('no tokens in hand')
      } else {
        --player.tokensInHand;
        ++regions[reg_i].tokensNum;
        events.exec('net.getGameState');
      }
    };
    events.reg_h('game.region.click',
                 'minor_modes.conquer->game.region.click',
                 plus);
    var minus = function(reg_i) {
      var regions = state.get('net.getGameState.gameState.regions');
      var regions_old = minor_modes.storage.defend.__old_regions__;
      var player = game.active_player();

      if (regions[reg_i].owner !== player.id || regions[reg_i].inDecline) {
        return;
      }

      if (!regions[reg_i].tokensNum) {
        alert('no tokens on region')
      } else if (regions[reg_i].tokensNum  == regions_old[reg_i].tokensNum) {
        alert("can't remove tokens from region during defend");
      } else {
        ++player.tokensInHand;
        --regions[reg_i].tokensNum;
        events.exec('net.getGameState');
      }
    };
    events.reg_h('game.region.image.click',
                 'minor_modes.conquer->game.region.image.click',
                 minus);
  },
  init : function() {
    minor_modes.storage.defend.__old_regions__ =
      deep_copy(state.get('net.getGameState.gameState.regions'));

    this._prepare_ui.call();
    this._prepare_map_actions.call();
    return 0;
  },
  uninit: function() {
    events.del_h('game.region.click',
                 'minor_modes.conquer->game.region.click');
    d3.select('form#finish_defend').remove();
    d3.select('form#undo_defend').remove();
  }
};

minor_modes.storage.waiting = {
  available_if: {
    major_m: ['play_game'],
    minor_m: ['in_game'],
    not_minor_m: ['conquer', 'redeploy', 'redeployed', 'defend',
                  'declined']
  },
  init : function() {
    game.state_monitor.start();
    return 0;
  },
  uninit: function() {
    game.state_monitor.stop();
  }
};

minor_modes.storage.enchant = {
  available_if: {
    minor_m: ['conquer']
  },
  _store_old_events: function() {
    minor_modes.storage.enchant.__old_events___ =
      events.storage.game.region.click;
    delete events.storage.game.region.click;
  },
  _restore_old_events: function() {
    events.del_h('game.region.click',
                 'minor_modes.enchant->game.region.click');

    var ench_mod = minor_modes.storage.enchant;
    if (!is_null(ench_mod.__old_events___)) {
      for (var i in ench_mod.__old_events___) {
        events.storage.game.region.click.push(ench_mod.__old_events___[i]);
      }
    }
  },
  _prepare_ui: function() {
    var on_resp = function(resp) {
      if (resp.result == 'ok') {
        minor_modes.storage.enchant._restore_old_events();
        minor_modes.disable('enchant');
        game.direct_request_game_state();
      } else {
        alert(resp.result);
      }
    };
    var h_onclick = function(reg_i) {
      net.send({"action":"enchant","regionId": reg_i + 1},
               on_resp);
    };
    var h = function() {
      if (!this.checked) {
        minor_modes.storage.enchant._restore_old_events();
      } else {
        minor_modes.storage.enchant._store_old_events();
        events.reg_h('game.region.click',
                     'minor_modes.enchant->game.region.click',
                     h_onclick);
      }
    };

    d3.select('div#actions')
      .append('form')
      .attr('id', 'form_enchant')
      .append('label').text('enchant')
      .append('input')
      .attr('type', 'checkbox')
      .on('click', h);
  },
  init : function() {
    this._prepare_ui();
    return 0;
  },
  uninit: function() {
    d3.select('form#form_enchant').remove();
  }
};

minor_modes.storage.dragon = {
  available_if: {
    minor_m: ['conquer']
  },
  // FIXME: copypaste from minor_modes.storage.enchant
  _store_old_events: function() {
    minor_modes.storage.dragon.__old_events___ =
      events.storage.game.region.click;
    delete events.storage.game.region.click;
  },
  _restore_old_events: function() {
    log.d.trace('minor_modes.storage.dragon._restore_old_events');

    events.del_h('game.region.click',
                 'minor_modes.dragon->game.region.click');

    var dragon_mod = minor_modes.storage.dragon;
    if (!is_null(dragon_mod.__old_events___)) {
      for (var i in dragon_mod.__old_events___) {
        events.storage.game.region.click.push(dragon_mod.__old_events___[i]);
      }
    }
  },
  _prepare_ui: function() {
    var on_resp = function(resp) {
      if (resp.result == 'ok') {
        minor_modes.storage.dragon._restore_old_events();
        minor_modes.disable('dragon');
        game.direct_request_game_state();
      } else {
        alert(resp.result);
      }
    };
    var h_onclick = function(reg_i) {
      net.send({"action":"dragonAttack","regionId": reg_i + 1},
               on_resp);
    };
    var h = function() {
      if (!this.checked) {
        minor_modes.storage.dragon._restore_old_events();
      } else {
        minor_modes.storage.dragon._store_old_events();
        events.reg_h('game.region.click',
                     'minor_modes.dragon->game.region.click',
                     h_onclick);
      }
    };

    d3.select('div#actions')
      .append('form')
      .attr('id', 'form_dragon')
      .append('label').text('use dragon')
      .append('input')
      .attr('type', 'checkbox')
      .on('click', h);
  },
  init : function() {
    this._prepare_ui();
    return 0;
  },
  uninit: function() {
    d3.select('form#form_dragon').remove();
  }
};

minor_modes.storage.berserk = {
  available_if: {
    minor_m: ['conquer']
  },
  _prepare_ui: function() {
    var on_resp = function(resp) {
      if (resp.result == 'ok') {
        alert('dice: ' + resp.dice)
        game.direct_request_game_state();
      } else {
        alert(resp.result);
      }
    };
    var h = function() {
      net.send({action: 'throwDice'}, on_resp);
    };
    d3.select('div#actions')
      .append('form')
      .attr('id', 'form_throw_dice')
      .append('input')
      .attr('type', 'submit')
      .attr('value', 'throw dice')
      .attr('onclick', 'return false;')
      .on('click', h);
  },
  init : function() {
    this._prepare_ui();
    return 0;
  },
  uninit: function() {
    d3.select('form#form_throw_dice').remove();
  }
};

Minor_Modes.have = function(mode) {
  return in_arr(mode, curr_modes.minor);
};

Minor_Modes._enable = function(mode, force, params) {
  if (in_arr(mode, curr_modes.minor)) {
    log.d.warn('mode ' + mode + ' already enabled');
    return 0;
  }

  var m_obj = this.storage[mode];
  if (is_null(m_obj)) {
    log.d.error('bad mode: ' + mode );
  }

  if (!_check_if_mod_available(m_obj, force)) {
    log.d.warn('mode is not avaible');
    return 0;
  }

  log.d.info("|minor mode| -> " + mode);
  log.d.dump(params, 'params');
  curr_modes.minor.push(mode);

  if (force) {
    if (!is_null(m_obj.available_if.not_minor_m)) {
      var c = m_obj.available_if.not_minor_m;
      var len = c.length;
      var i = 0;
      for (; i < len; ++i) {
        minor_modes.disable(c[i]);
        if (c.length < len) {
          len = c.length;
          i = 0;
        }
      }
    }
  }

  log.ui.modes(curr_modes);

  if (!this.storage[mode].init(params)) {
    return 0;
  }

  ui.create_menu();

  return 1;
};

Minor_Modes.is_enabled = function(mode) {
  return in_arr(mode, curr_modes.minor);
};

Minor_Modes.enable = function(mode, params) {
  return this._enable(mode, 0, params);
};

Minor_Modes.force = function(mode, params) {
  return this._enable(mode, 1, params);
};

Minor_Modes.disable = function(mode) {

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

  log.ui.modes(curr_modes);
  return 1;
};
