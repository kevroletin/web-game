
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
    return msg
  }
};

Errors.funct.badUserSid = function(resp) {
  major_modes.change('login');
  alert('Invalid user sid.');
};

// TODO: write descriptions
Errors.table = {
  /* Login */
  badUsernameOrPassword          : 'Bad username or password',
  badUsername                    : 'Bad username',
  badPassword                    : 'Bad password',
  /* Register */
  usernameTaken                  : 'Username taken',
  /* New Game */
  badGameName                    : 'Bad game name',
  badGameDescription             : 'Bad game description',
  /* Play Game */
  badStage                       : 'Bad game stage',
  badRegion                      : 'Bad region',
  notEnoughTokensForRedeployment : 'Not enough tokens for redeployment',
  badTokensNum                   : 'Bad tokens num',
  badRegion                      : 'Bad region',
  tooManyFortifiedsInRegion      : 'Too many fortifieds in region',
  canNotAttackFriend             : 'Can not attack friend'
};
