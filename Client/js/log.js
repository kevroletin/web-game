
function debug_log_type() {}
function ui_log_type() {}

var log = {
  d: new debug_log_type(),
  ui: new ui_log_type()
};

var Debug_Log = debug_log_type.prototype;
var Ui_Log = ui_log_type.prototype;

/* Debug log */

Debug_Log.info = function(msg) { console.info('[info] ' + msg) };

Debug_Log.warn = function(msg) { console.warn('[warn] ' + msg) };

Debug_Log.error = function(msg) { console.error('[error] ' + msg) };
//dump: function(obj) { console.dir(obj) }

Debug_Log.dump = function(obj, descr) {
  var t = '';
  if (descr) { t = descr + ': ' }
  console.info(t + JSON.stringify(obj))
};

Debug_Log.pretty = function(obj, descr) {
  console.info(JSON.stringify(obj, null, ' '))
};

//Debug_Log.events = function(msg) {}
Debug_Log.events = function(msg) {
  console.warn('[events] ---' + msg + '---')
}

//Debug_Log.trace = function() {}
Debug_Log.trace = function(funct_name) { 
  console.warn('[trace] ---' + funct_name + '---')
}

/* UI log */

Ui_Log.init = function() {
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
};

Ui_Log._get_ui_log = function() {
  var log = this.init();
  this._get_ui_log = function() { return log }
  return log;
};

Ui_Log._append_log = function(msg) {
  var l = this._get_ui_log();
  l.append('pre').text(msg);
  l.node().scrollIntoTop = l.node().scrollHeight;
};

Ui_Log.info = function(msg) { this._append_log('[info] ' + msg) };

Ui_Log.warn = function(msg) { this._append_log('[warn] ' + msg) };

Ui_Log.error = function(msg) { alert('[error]' + mgs);
                              //this._append_log('[error] ' + msg)
                            };

Ui_Log.dump = function(obj, descr) {
  var t = '';
  if (descr) { t = descr + ': ' }
  this._append_log(t + JSON.stringify(obj))
},

Ui_Log.pretty = function(obj, descr) {
  this._append_log(JSON.stringify(obj, null, ' '))
};

Ui_Log._modes_init = function() {
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
};

Ui_Log._get_modes_log = function() {
  var log = this._modes_init();
  this._get_modes_log = function () { return log }
  return log
};

Ui_Log.modes = function(modes) {
  var l = this._get_modes_log();
  l.text(JSON.stringify(modes, null, ' '));
};
