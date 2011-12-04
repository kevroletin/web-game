
function server_url() {
  return 'engine';
}

function rsc(type) {
  var storage = {
    'img': 'import/client/css/images',
    'img.rc.s': function(race) {
      if (is_null(race)) race = 'nobody';
      return 'img/rc/s/' + race + '.jpg';
    },
    'img.powers': 'import/client/css/images/specialPowers',
    'js': 'js',
    'css': 'css'
  };

  return storage[type];
}
