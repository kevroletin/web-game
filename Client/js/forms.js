
function ui_forms_type() {}

var ui_forms = new ui_forms_type();
var Ui_Forms = ui_forms_type.prototype;

Ui_Forms._gen_simple_form = function(form_name) {
  log.d.trace('Ui_Forms._gen_simple_form');

  var obj = this[form_name];
  var f = make('form')


  f.attr('id', obj.id).
    attr('onSubmit', 'ui_forms.' + form_name +
         '.checker(this); return false');
  var ff = f.append('fieldset');
  ff.append('legend').text(obj.descr);
  ff.append('p').attr('id', 'msg_box');

  t = ff.append('table');

  ff.selectAll('tr').data(obj.fields)
    .enter()
    .append('tr')
    .each(function(d) {
      var tr = d3.select(this)
      tr.append('td')
        .text(d.descr);
      tr.append('td')
        .append('input')
        .attr('name', d.name)
        .attr('type', d.type ? d.type : 'text');
    });
  ff.append('input')
    .attr('name', 'ok')
    .attr('type', 'submit')
    .attr('value', 'ok');

  return f.node();
};

Ui_Forms.login = {
  id: "login",
  descr: "Login",
  fields: [{name: "username", descr: "Username"},
           {name: "password", descr: "Password", type: "password"}],
  gen_form: function() { return ui_forms._gen_simple_form('login'); },
  checker: function(f) {
    var name = f['username'].value;
    var pasw = f['password'].value;

    var q = { action: "login",
              username: name,
              password: pasw };
    net.send(q, this['_on_resp'] );

    return false;
  },
  _show_err: function(field, err) {
    log.ui.error(field + ': ' + err);
  },
  _on_resp: function (resp) {
    d3.select('p#msg_box').text(resp.result);
    if (resp.result == 'ok') {
      state.store('sid', resp.sid);
      state.store('userId', resp.userId);
      events.exec('state.sid_stored');
      events.exec('login.success', resp);
    }
  }
};

Ui_Forms.register = {
  id: "register",
  descr: "Register",
  fields: [{name: "username", descr: "Username"},
           {name: "password", descr: "Password", type: "password"},
           {name: "password2", descr: "Password2", type: "password"}],
  gen_form: function() { return Ui_Forms._gen_simple_form('register'); },
  checker: function(f) {
    var name = f['username'].value;
    var pasw = f['password'].value;
    var pasw2 = f['password2'].value;

    var q = { action: "register",
              username: name,
              password: pasw };
    net.send(q, this['_on_resp'] );

    return false;
  },
  _show_err: function(field, err) {
    log.ui.error(field + ': ' + err);
  },
  _on_resp: function (resp) {
    d3.select('p#msg_box').text(resp.result);
  }
};

Ui_Forms.game_list = {
  gen_form: function(game_list) {

    var t = make('table');
    t.append('tr').selectAll('th')
      .data(['Название', 'Описание', 'Состояние', 'Игроков'])
      .enter()
      .append('th')
      .text(String);

    t.selectAll('td').data(game_list).enter()
      .append('tr')
      .each(function(d) {
        var tr = d3.select(this);
        var on_txt = 'major_modes.change(\'explore_game\', ' +
          d.gameId + '); return false;'
        tr.append('a')
          .attr('onclick', on_txt)
          .attr('href', '#')
          .text(d.gameName);

        tr.selectAll(null).data(
          [d.gameDescr, d.state,
           d.maxPlayersNum + '/' + d.playersNum])
          .enter()
          .append('td')
          .text(String);
      });

    return t.node();
  }
};

Ui_Forms.maps_list = {
  gen_form: function(maps_list) {

    var t = make('table');
    t.append('tr').selectAll('th')
      .data(['Название', 'Игроков', 'Размер', 'Ходов'])
      .enter()
      .append('th')
      .text(String);

    t.selectAll('td').data(maps_list).enter()
      .append('tr')
      .each(function(d) {
        var tr = d3.select(this);
        var on_txt = 'major_modes.change(\'explore_map\', ' +
          d.mapId + '); return false;'
        tr.append('a')
          .attr('onclick', on_txt)
          .attr('href', '#')
          .text(d.mapName);

        tr.selectAll(null).data(
          [d.playersNum, d.regionsNum, d.turnsNum])
          .enter()
          .append('td')
          .text(String);
      });

    return t.node();
  }
};

function ui_elements_type() {}

var ui_elements = new ui_elements_type();
var Ui_Elements = ui_elements_type.prototype;

Ui_Elements.menu = function(modes_list) {
  log.d.trace('Ui_Elements.menu');

  var m = make('ul');
  m.selectAll('li')
    .data(modes_list).enter()
    .append('li')
    .attr('onclick',
          function(d) {
            return 'major_modes.change(\'' + d.name + '\')'
          })
    .attr('id', function(d) { return 'nav_' + d.name + '' })
    .text(function(d) { return d.obj.descr });

  return m.node();
};

Ui_Elements._append_player_info = function(gameInfo, data_enter) {
  log.d.trace('Ui_Elements._append_player_info');


  function u_inf_game_not_started(d, t) {
    t.append('div')
      .classed('readiness_status', 1)
      .text('ready: ' + yes_or_no(d.readinessStatus));
    if (d.id == state.get('userId')) {
      t.append('form')
        .attr('onsubmit', 'return false;')
        .append('input')
        .attr('type', 'submit')
        .attr('name', 'readiness')
        .attr('value',
              choose(d.readinessStatus, ['ready', 'wait']))
        .on('click', function(d) {
          var t = d3.select(this);
          a = ['ready', 'wait'],
          val = zero_or_one(this.value == 'ready');

          t.attr('value', a[val]);
          var q = {action: 'setReadinessStatus',
                   isReady: val};
          var h = function(resp) {
            if (resp.result == 'ok') {
              t.attr('value', a[val])
            } else {
              var e = 'Problem with setting readiness status';
              alert(e);
              log.d.error(e);
              log.d.dump(q, 'query');
              log.d.dump(resp, 'response');
            }
          };
          net.send(q, h);
          return false;
        });
    }
  }

  function u_inf_game_started(d, t) {
    t.append('div')
      .classed('in_decline', 1)
      .text('in decline: ' +
            choose(d.inDecline, ['no', 'yes']));
    t.append('div')
      .classed('tokens_in_hand', 1)
      .text('tokens in hand: ' + zero_if_null(d.tokensInHand));
    t.append('div')
      .classed('active_race', 1)
      .text('active race: ' + no_if_null(d.activeRace));
    t.append('div')
      .classed('active_power', 1)
      .text('active power: ' + no_if_null(d.activePower));
      t.append('div')
      .classed('decline_race', 1)
      .text('decline race: ' + no_if_null(d.declineRace));
    t.append('div')
      .classed('decline_power', 1)
      .text('decline power: ' + no_if_null(d.declinePower));
  }

  data_enter
    .append('div')
    .attr('id', function(d, i) { return 'player_' + i })
    .classed('player', 1)
    .classed('active_player',
             function(d, i) { return i == gameInfo.activePlayerNum; })
    .each(function(d) {
      var t = d3.select(this);
      t.append('div')
       .classed('username', 1)
       .text(d.name);

      if (gameInfo.state == 'notStarted') {
        u_inf_game_not_started(d, t);
      } else {
        u_inf_game_started(d, t);
      }
    });
};

Ui_Elements.game_info = function(gameInfo, d) {
  log.d.trace('Ui_Elements.game_info');

  d.append('h1').text(gameInfo.gameName);
  d.append('div').text('game state: ' + gameInfo.state);
  var data = d.append('div').attr('id', 'players')
    .selectAll('div')
    .data(gameInfo.players);
  this._append_player_info(gameInfo, data.enter());

  div_game_info
    .append('div')
    .attr('id', 'tokens_packs');

  return d.node();
};

Ui_Elements._update_players_info = function(game_state, div) {
  log.d.trace('Ui_Elements._update_players_info');

  if (is_null(game_state)) {
    game_state = state.get('net.getGameState.gameState',
                           'net.getGameInfo.gameInfo');
  }
  if (is_null(div)) {
    div = d3.select('div#game_info');
  }

  var data = div.selectAll('div.player')
    .data(game_state.players)
    .classed('active_player',
             function(d, i) { return i == game_state.activePlayerNum; })
    .each(function(d) {
      var t = d3.select(this);
      t.select('div.in_decline')
        .text('in decline: ' +
              choose(d.inDecline, ['no', 'yes']));
      t.select('div.tokens_in_hand')
        .text('tokens in hand: ' +
              zero_if_null(d.tokensInHand));
      t.select('div.active_race')
        .text('active race: ' + no_if_null(d.activeRace));
      t.select('div.active_power', 1)
        .text('active power: ' + no_if_null(d.activePower));
      t.select('div.decline_race', 1)
        .text('decline race: ' + no_if_null(d.declineRace));
      t.select('div.decline_power', 1)
        .text('decline power: ' + no_if_null(d.declinePower));
    });
}

Ui_Elements._update_token_badges = function(game_state, div) {
  log.d.trace('Ui_Elements._update_token_badges');

  if (is_null(game_state)) {
    game_state = state.get('net.getGameState.gameState',
                           'net.getGameInfo.gameInfo');
  }
  if (is_null(div)) {
    div = d3.select('div#tokens_packs')
  }

  var tok = game_state.visibleTokenBadges;

  var data = div.selectAll('div.tokens_pack')
    .data(tok);

  data
    .enter()
    .append('div')
    .each(function(d, i) {
      var t = d3.select(this)
        .attr('class', 'tokens_pack');
      t.append('div').text(d.raceName);
      t.append('div').text(d.specialPowerName);
      t.append('div').text(d.bonusMoney);
      d.position = i;
    });

  data.enter()
    .append('div')
    .each(function(d, i) {
      var t = d3.select(this)
        .attr('class', 'tokens_pack');
      t.append('div').text(d.raceName);
      t.append('div').text(d.specialPowerName);
      t.append('div').text(d.bonusMoney);
      d.position = i;
    });

  data.each(function(d) {
    d3.select(this).selectAll('div')
      .data([d.raceName, d.specialPowerName,
             d.bonusMoney])
      .text(String);
  });
}

Ui_Elements.update_game_info = function() {
  log.d.trace('Ui_Elements.update_game_info');

  this._update_players_info();
  this._update_token_badges();
};

function playfield_type() {}

var playfield = new playfield_type;
var Playfield = playfield_type.prototype;

Playfield.create = function(svg, map) {
  log.d.trace('Playfield.create');

  svg
    .attr('class', 'playfield')
    .attr('width', 750)
    .attr('height', 550);

  var bg = ['swamp', 'hill', 'forest', 'farmland', 'mountain',
            'sea'];

  var df = svg.append('defs').selectAll('pattern')
    .data(bg)
  .enter()
    .append('svg:pattern')
    .attr('id', function(d) { return 'bg_' + d })
    .attr('patternUnits', "userSpaceOnUse")
    .attr('x', "0")
    .attr('y', "0")
    .attr('width', "50")
    .attr('height', "50")
    .attr('viewBox', "0 0 50 50")
    .append('svg:image')
      .attr('xlink:href', function(d) { return rsc('img.bg')(d) })
      .attr('width', 50)
      .attr('height', 50)
      .attr('x', 0)
      .attr('y', 0);

//move playfield to right and get place to tokens storage
  var field = svg.append('svg:g')
      .attr("transform", "translate(100,15)");

  var reg = field.append('g').attr('id', 'regions');
  var extra = field.append('g').attr('id', 'extra_items');
  var free_tks = field.append('g').attr('id', 'free_tokens');
  var tks = field.append('g').attr('id', 'tokens');

  var line = d3.svg.line();

  tks.selectAll('g')
    .data(map.regions)
  .enter()
    .append('g')
    .attr('id', function(d, i) { return 'tok_' + i })
    .each(function(d, i) { this.constState = d })

  var reg_g = reg.selectAll('path')
    .data(map.regions)
  .enter()
    .append('svg:g')
    .attr('id', function(d, i) { return 'm_r_' + i })
    .on('click', function(d, i) { events.exec('game.region.click', i)});

  reg_g.append("svg:path")
    .style('fill', function(d) {
      var res = d.landDescription.filter(function(d) {
        return in_arr(d, bg);
      });
      return 'url(#bg_' + res[0] + ')';
    })
    .attr('class', function(d) {
      return 'm_r , ' +
        d.landDescription
        .map(function(e) { return 'm_r_t_' + e })
        .join(' ');
    })
    .attr("d", function(d) { return line(d.coordinates) + 'Z' })
    .each(function(d, i) {
      var ps = d3.select(this);
      ps.append('animate')
        .attr('attributeName', 'stroke')
        .attr('id', 'm_r_' + i + '_a1')
        .attr('to', 'red')
        .attr('dur', '0.2s')
        .attr('fill', 'freeze')
        .attr('repeatCount', 1)
        .attr('begin', 'm_r_' + i + '.mouseover');
      ps.append('set')
        .attr('attributeName', 'stroke-width')
        .attr('to', '1')
        .attr('begin', 'm_r_' + i + '_a1.begin');
      ps.append('set')
        .attr('attributeName', 'stroke-width')
        .attr('to', '0')
        .attr('begin', 'm_r_' + i + '.mouseout');
      ps.append('set')
        .attr('attributeName', 'stroke')
        .attr('to', 'transparent')
        .attr('begin', 'm_r_' + i + '.mouseout');
    });

  reg_g.each(function(d, i) {
    var g = d3.select(this);

    ['magic', 'mine', 'cavern'].forEach(function(extra_item) {
      var field = extra_item + 'Coords';
      log.d.info(field);

      if (!is_null(d[field])) {
        g.append('svg:image')
          .attr('xlink:href', function(d) { return rsc('img.ex')(extra_item) })
        .attr('width', 50)
          .attr('height', 50)
          .attr('x', d[field][0])
          .attr('y', d[field][1]);
      }
    })
  });


/*
  extra.selectAll('img')
    .data(map.regions)
  .enter()
    .append('g')
    .attr('id', function(d, i) { return "etok_" + i })
  });
*/


  return svg.node();
};

Playfield.apply_game_state = function(game_state) {
  log.d.trace('Playfield.apply_game_state');

//  log.d.pretty(gameState);
  if (is_null(game_state)) {
    game_state = state.get('net.getGameState.gameState',
                           'net.getGameInfo.gameInfo');
  }

  var tks = d3.select('g#tokens');
  tks.selectAll('g')
    .data(game_state.regions)
    .each(function(d, i) {

      var cs = this.constState;
      var data = d3.select(this).selectAll('image')
                   .data(d3.range(0, d.tokensNum));
      var race = determine_race(game_state, d);
      data.enter().append('svg:image')
      data.exit().remove();
      d3.select(this).selectAll('image')
        .attr('x', function(d, i) { return (cs.raceCoords[0] + i*4) })
        .attr('y', function(d, i) { return (cs.raceCoords[1] + i*4) })
        .attr('width', '50px')
        .attr('height', '50px')
        .attr('xlink:href', rsc('img.rc.s')(race) )
        .on('click',
            function(d) { events.exec('game.region.image.click', i)});;
    });

  var free_tks = d3.select('g#free_tokens');
  var data = free_tks.selectAll('g').data(game_state.players);
  data.enter().
    append('svg:g')
    .attr('id', function(d, i) { return 'ftoks_' + i });
  free_tks.selectAll('g')
    .each(function(d, player_i) {
      var r = d3.range(0, d.tokensInHand);
      var race = game_state.players[player_i].activeRace;
      var data = d3.select(this).selectAll('image').data(r);
      data.exit().remove();
      data.enter().append('svg:image');
      d3.select(this).selectAll('image').data(r)
        .attr('x', function(d, i) { return ( -100 + i*4) })
        .attr('y', function(d, i) { return ( player_i*70 + i*4) })
        .attr('width', '50px')
        .attr('height', '50px')
        .attr('xlink:href', rsc('img.rc.s')(race) );
    });
};
