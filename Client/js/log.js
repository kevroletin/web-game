
function debug_log_type() {}
function ui_log_type() {}

var log = {
  d: new debug_log_type(),
  ui: new ui_log_type()
};

var debug_log_proto = debug_log_type.prototype;
var ui_log_proto = ui_log_type.prototype;

/* Debug log */

debug_log_proto.info = function(msg) { console.info('[info] ' + msg) };

debug_log_proto.warn = function(msg) { console.warn('[warn] ' + msg) };

debug_log_proto.error = function(msg) { console.error('[error] ' + msg) };
//dump: function(obj) { console.dir(obj) }

debug_log_proto.dump = function(obj, descr) {
  var t = '';
  if (descr) { t = descr + ': ' }
  console.info(t + JSON.stringify(obj))
};

debug_log_proto.pretty = function(obj, descr) {
  console.info(JSON.stringify(obj, null, ' '))
};

debug_log_proto.events = function(msg) {}

/* UI log */

ui_log_proto.init = function() {
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

ui_log_proto._get_ui_log = function() {
  var log = this.init();
  this._get_ui_log = function() { return log }
  return log;
};

ui_log_proto._append_log = function(msg) {
  var l = this._get_ui_log();
  l.append('pre').text(msg);
  l.node().scrollIntoTop = l.node().scrollHeight;
};

ui_log_proto.info = function(msg) { this._append_log('[info] ' + msg) };

ui_log_proto.warn = function(msg) { this._append_log('[warn] ' + msg) };

ui_log_proto.error = function(msg) { alert('[error]' + mgs);
                              //this._append_log('[error] ' + msg)
                            };

ui_log_proto.dump = function(obj, descr) {
  var t = '';
  if (descr) { t = descr + ': ' }
  this._append_log(t + JSON.stringify(obj))
},

ui_log_proto.pretty = function(obj, descr) {
  this._append_log(JSON.stringify(obj, null, ' '))
};

ui_log_proto._modes_init = function() {
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

ui_log_proto._get_modes_log = function() {
  var log = this._modes_init();
  this._get_modes_log = function () { return log }
  return log
};

ui_log_proto.modes = function(modes) {
  var l = this._get_modes_log();
  l.text(JSON.stringify(modes, null, ' '));
};
