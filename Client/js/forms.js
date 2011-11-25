
var ui_forms = {

  _gen_simple_form: function(form_name) {
    var obj = this[form_name];
    var f = 
      $('<form id="' + obj.id + '"' +
        'onSubmit=\"ui_forms.' + form_name +
        '.checker(this); return false\" />');
    var i, field, field_t, ff, t;
    ff = 
      $('<fieldset>').append(
        $('<legend>' + obj.descr +'</legend>'),
        $('<p id="msg_box"></p>'));
    t =
      $('<table>');
    for (i = 0; i < obj.fields.length; ++i) {
      field = obj.fields[i];
      field_t = field.type ? field.type : 'text';
      t.append('<tr><td>' + field.descr + '</td><td>' +
               '<input name="' + field.name + '" type="' + field_t + 
               '" /></td></tr>');
    }
    ff.append(t);
    ff.append('<input type="submit" name=\"ok\" value=\"ok\" />');
    f.append(ff);
    return f;
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
      $('p#msg_box')[0].textContent = resp.result;
      if (resp.result == 'ok') {
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
      $('p#msg_box')[0].textContent = resp.result;
    }
  },

  game_list: {
    gen_form: function(game_list) {
      /* TODO: rework and move to another module */
      var t = $('<table id="gamesList">');
      if (game_list.length == 0) { return 0; }
      
      var tr = $('<tr>');
      var a = ['Название', 'Описание', 'Состояние', 'Игроков'];
      for (var i in a) {
        tr.append($('<th>' + a[i] + '</th>'));
      }
      t.append(tr);
      
      for (var i in game_list) {
        var g = game_list[i];
        var tr = $('<tr>');
        var td = [];
        var a = '<a onclick="ui.set_major_mode(\'explore_game\', ' + 
                g.gameId + '); return false;" href="#">' + 
                g.gameName + '<a>';
        td.push(a);
        td.push(g.gameDescr);
        td.push(g.state);
        td.push(g.maxPlayersNum + '/' + g.playersNum);
        for (var j in td) {
          tr.append($('<td>' + td[j] + '</td>'));
        }
        t.append(tr);
      }
      return t;
    }

  },

};

var ui_elements = {
  menu: function(modes_list) {
    var m = $("<ul>");
    for (var i = 0; i < modes_list.length; ++i) {
      var mod = modes_list[i];
      m.append('<li onclick="ui.set_major_mode(\'' + mod.name +
               '\')">' + mod.obj.descr + '</li>');
    }
    return m;
  }
};
