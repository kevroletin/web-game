
var log = {
  d: {
    info: function(msg) { console.info('[info] ' + msg) },
    warn: function(msg) { console.warn('[warn] ' + msg) },
    error: function(msg) { console.error('[error] ' + msg) },
    //dump: function(obj) { console.dir(obj) }
    dump: function(obj, descr) { 
      var t = '';
      if (descr) { t = descr + ': ' }
      console.info(t + JSON.stringify(obj))
    },
    pretty: function(obj, descr) { 
      console.info(JSON.stringify(obj, null, ' '))
    },
    events: function(msg) {}
  },
  ui: {
    init: function() { 
      return d3.select('body')
        .append('div')
        .classed('debug_log', 1)
        .style('width', '300px')
        .style('height', '300px')
        .style('position', 'absolute')
        .style('background-color', 'white')
        .style('border', '1px black solid')
        .style('right', 0)
        .style('top', 0)
        .style('overflow', 'scroll');
    },

    _get_ui_log: function() { 
      var log = this.init();
      this._get_ui_log = function() { return log }
      return log;
    },
    _append_log: function(msg) {
      var l = this._get_ui_log();
      l.append('pre').text(msg);
      l.node().scrollIntoTop = l.node().scrollHeight;
    },
    info: function(msg) { this._append_log('[info] ' + msg) },
    warn: function(msg) { this._append_log('[warn] ' + msg) },
    error: function(msg) { alert('[error]' + mgs);
      //this._append_log('[error] ' + msg) 
    },
    dump: function(obj, descr) { 
      var t = '';
      if (descr) { t = descr + ': ' }
      this._append_log(t + JSON.stringify(obj))
    },
    pretty: function(obj, descr) { 
      this._append_log(JSON.stringify(obj, null, ' '))
    },

    _modes_init: function() {
      var div = d3.select('body')
        .append('div')
          .classed('debug_modes_log', 1)
          .style('width', '180px')
          .style('height', '300px')
          .style('position', 'absolute')
          .style('background-color', 'white')
          .style('border', '1px black solid')
          .style('left', 0)
          .style('top', '300px')
          .style('overflow', 'scroll')
      return div.append('pre');
    },
    _get_modes_log: function() {
      var log = this._modes_init();
      this._get_modes_log = function () { return log }
      return log
    },
    modes: function(modes) {
      var l = this._get_modes_log();
      l.text(JSON.stringify(modes, null, ' '));
    }
  },
};
