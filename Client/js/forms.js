var ui_forms = {

  _gen_simple_form: function(form_name) {

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
  },

  login: {
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
        events.exec('state.sid_stored');
        events.exec('login.success', resp);
      }
    }
  },

  register: {
    id: "register",
    descr: "Register",
    fields: [{name: "username", descr: "Username"},
             {name: "password", descr: "Password", type: "password"},
             {name: "password2", descr: "Password2", type: "password"}],
    gen_form: function() { return ui_forms._gen_simple_form('register'); },
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
  },

  game_list: {
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
          var on_txt = 'ui.set_major_mode(\'explore_game\', ' + 
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
  }, 

  maps_list: {
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
          var on_txt = 'ui.set_major_mode(\'explore_map\', ' + 
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

  }, 


};

var ui_elements = {};

ui_elements.menu = function(modes_list) {
  var m = make('ul');
  m.selectAll('li')
    .data(modes_list).enter()
    .append('li')
    .attr('onclick',
          function(d) { 
            return 'ui.set_major_mode(\'' + d.name + '\')' 
          })
    .attr('id', function(d) { return 'nav_' + d.name + '' })
    .text(function(d) { return d.obj.descr });
  
  return m.node();
};

ui_elements.game_info = function(gameInfo) {
  log.d.pretty(gameInfo);

  var d = make('div').attr('id', 'game_info');
  d.append('h1').text(gameInfo.gameName);
  d.append('div').attr('id', 'players').selectAll('div')
    .data(gameInfo.players)
  .enter()
    .append('div')
    .attr('id', function(d, i) { return 'player_' + i })
    .classed('player', 1)
    .each(function(d) {
      var t = d3.select(this);
      t.append('div')
       .classed('username', 1)
       .text(d.name);
      t.append('div')
       .classed('in_decline', 1)
       .text('in decline: ' + 
              choose(d.inDecline, ['no', 'yes']));
      t.append('div')
       .classed('tokens_in_hand', 1)
       .text('tokens in hand: ' + zero_if_null(d.tokensInHand));
      t.append('div')
       .classed('active_race', 1)
        .text('active race: ' + d.activeRace);
      t.append('div')
       .classed('active_power', 1)
        .text('active power: ' + d.activePower);
      t.append('div')
       .classed('decline_race', 1)
        .text('decline race: ' + d.declineRace);
      t.append('div')
       .classed('decline_power', 1)
        .text('decline power: ' + d.declinePower);
    });

  return d.node();
};

var playfield = {};

playfield.create = function(map) {

  var svg = make('svg')
             .attr('xmlns', "http://www.w3.org/2000/svg") 
//             .attr('xmlns:xlink', "http://www.w3.org/1999/xlink")
             .classed('playfield', 1)
             .attr('width', 500)
             .attr('height', 500);

  var reg = svg.append('g').attr('id', 'regions');
  var tks = svg.append('g').attr('id', 'tokens');
  
  var line = d3.svg.line();

  tks.selectAll('g')
    .data(map.regions)
  .enter()
    .append('g')
    .each(function(d, i) { this.constState = d })

  reg.selectAll('path')
    .data(map.regions)
  .enter()
    .append("svg:path")
    .attr('id', function(d, i) { return 'm_r_' + i })
    .attr('class', function(d) {
      return 'm_r , ' + d.landDescription
        .map(function(e) { return 'm_r_t_' + e })
        .join(' , ');
    })
    .attr("d", function(d) { return line(d.coordinates) + 'Z' })
    .each(function(d, i) { svg.append })
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
        .attr('to', '2')
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

  return svg.node();
};

playfield.apply_game_state = function(svg, gameState) {
//  log.d.pretty(gameState);

  var tks = d3.select(svg).select('g#tokens');
  tks.selectAll('g')
    .data(gameState.regions)
    .each(function(d, i) {
      var cs = this.constState;
      var data = d3.select(this).selectAll('image')
                   .data(d3.range(0, d.tokensNum));
      var race = determine_race(gameState, d);
      data.enter()
        .append('svg:image')
        .attr('x', function(d, i) { return (cs.raceCoords[0] + i*4) })
        .attr('y', function(d, i) { return (cs.raceCoords[1] + i*4) })
        .attr('width', '50px')
        .attr('height', '50px')
        .attr('xlink:href', rsc('img.rc.s')(race) );
      data.exit().remove();

    });
};
