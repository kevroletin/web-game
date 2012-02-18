
function errors_type() {};

var errors = new errors_type();

var Errors = errors_type.prototype;

Errors.funct = {};

Errors.server_is_died = function(resp) {
  alert('Problems with server');
  return 'Problems with server';
};

Errors.descr_resp = function(resp) {
  if (is_null(resp) || is_null(resp.result)) {
    return Errors.server_is_died(resp);
  }
  if (resp.result == 'ok') {
    return 'ok';
  }
  if (!is_null(errors.funct[resp.result])) {
    return errors.funct[resp.result]();
  }
  var res = Errors.translate(resp.result);
  alert(res);
  return res;
};

Errors.translate_resp = function(resp) {
  if (is_null(resp) || is_null(resp.result)) {
    Errors.server_is_died(resp);
    return 'Problems with server';
  }
  return Errors.translate(resp.result)
}

Errors.translate = function (msg) {
  if (!is_null(Errors.table[msg])) {
    return Errors.table[msg];
  } else {
    return _beautify_err_code(msg)
  }
};

Errors.funct.badUserSid = function(resp) {
  major_modes.change('login');
  alert('Invalid user sid.');
};

// TODO: write descriptions
Errors.table = {
  /* Play Game */
  badStage                       : 'Bad game stage',
  nothingToEnchant               : 'There is no tockens on resion to enchant'
};

function _beautify_err_code(err) {
  var up_case = /[A-Z]/;
  var j = 1;
  var result = err.charAt(0).toUpperCase();
  for (var i = 1; i <= err.length; ++i) {
    if (up_case.test(err.charAt(i)) || i == err.length) {
      result = result + err.substring(j, i).toLowerCase() + ' ';
      j = i;
    }
  }
  return result.substr(0, result.length - 1);
}
