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

};

var ui_elements = {
  menu: function(modes_list) {
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
  }
};
