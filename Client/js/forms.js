
var ui_forms = {

  login: {
    id: "login",
    descr: "Login",
    fields: [{name: "username", descr: "Username"},
             {name: "password", descr: "Password", type: "password"}],
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
    }
  },

  register: {
    id: "register",
    descr: "Register",
    fields: [{name: "username", descr: "Username"},
             {name: "password", descr: "Password", type: "password"},
             {name: "password2", descr: "Password2", type: "password"}],
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

  gen_form: function(form_name) {
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
  }

};
