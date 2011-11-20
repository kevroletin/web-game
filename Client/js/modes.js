
var major_modes = {

  change_mode: function(menu, content, curr_modes, new_m) {
    /* TODO: raise error if we want to go into major mode which
       can not be used with active minor mode */
    /* TODO: disable needed minor modes */

    if (!is_null(curr_modes.major) &&
        !is_null(this.storage[curr_modes.major].uninit)) {
      this.storage[curr_modes.major].uninit();
    }
    this.storage[new_m].init(content);
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
          .append(ui_forms.gen_form('login'));

        var h_sid = function(data) { 
          log.d.info('sid: ' + data.sid);
        };
        var h_ui = function() {
          events.exec('ui.refresh_menu');
        };
        events.reg_h('login.success', 'store_sid', h_sid);
        events.reg_h('login.success', 'logined_update_ui', h_ui);
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
        net.send(q, function() { events.exec('loguot.success') });
      },
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
    if (!(mode in curr_modes.minor)) {
      return curr_modes;
    }
    for (var i = 0; i < curr_modes.minor; ++i) {
      if (curr_modes.minor[i] == mode) {
        curr_modes.minor.splice(i, 1);
        break;
      }
    }
    return curr_modes;
  },

  storage: {
    logined: {
      init: function() { 
        /* noting to do. Ui updates will be done via events */
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
