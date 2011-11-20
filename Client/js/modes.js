
var major_modes = {

  change_mode: function(menu, content, curr_modes, new_m) {
    /* TODO: raise error if we want to go into major mode which
       can not be used with active minor mode */
    /* TODO: disable needed minor modes */

    if (!is_null(curr_modes.major)) {
      this.storage[curr_modes.major].uninit();
    }
    this.storage[new_m].init(content);
    curr_modes.major = new_m;
    this.create_menu(menu, curr_modes);
    return curr_modes;
  },
  
  create_menu: function(menu, curr_modes) {
    var res = [];
    for (var i in this.storage) {
      var m = this.storage[i];
      if (!(is_null(m.in_menu) || !m.in_menu) &&
           this._check_if_mod_available(
                   curr_modes, m))
      {
        res.push({name: i, obj: this.storage[i]});
      }
    }  
    this._gen_menu_html(menu, res)
  },

  _gen_menu_html: function(menu, modes_list) {
    var m = $("<ul>");
    log.d.dump(menu);
    for (var i = 0; i < modes_list.length; ++i) {
      var mod = modes_list[i];
      m.append('<li onclick="ui.setMode(\'' + mod.name +
               '\')">' + mod.obj.descr + '</li>');
    }
    menu.empty().append(m);
  },

  _check_if_mod_available: function(curr_modes, m_obj) {
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
        ok = c[i] in curr_modes.minor
      }
      if (!ok) { return false; }
    }
    if (!is_null(m_obj.available_if.not_minor_m)) {
      var c = m_obj.available_if.not_minor_m;
      for (var i = 0; i < c.length && !ok; ++i) {
        if (c[i] in curr_modes.minor) {
          return false;
        }
      }
    }
    
    return true;
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
          .append(ui_forms.gen_form('login'));

        var h = function(data) { 
          log.d.info('sid: ' + data.sid);
        }
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
/*      should_disable: {
        minor_m: [],
        not_minor_m: []
      }, */
      in_menu: true,
    },

    register: {
      descr: 'Register',
      in_menu: true,
      init: function(content) {
        content.empty()
          .append(ui_forms.gen_form('register'));
      },
      uninit: function() {
      }
    },

    games_list: {
      descr: 'Games list',
      in_menu: true,

    },

    explore_game: {
      descr: 'Explore game',
      in_menu: false,
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
    },

    explore_map: {
      descr: 'Explore map',
      in_menu: false
    }
  }
  
};

var minor_modes = {
  
  logined: {

  },

};

