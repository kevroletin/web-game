
function rsc(type) {
  var storage = {
    'img': 'import/client/css/images',
    'img.bg': function(bg) { return 'img/bg/' + bg + '.jpg' },
    'img.ex': function(item) { return 'img/ex/' + item + '.jpg' },
    'img.rc.s': function(race) {
      if (is_null(race)) race = 'nobody';
      return 'img/rc/s/' + race + '.jpg';
    },
    'img.rc': function(race, in_decline) {
      if (is_null(race)) { race = 'nobody' }
      if (in_decline) { race += '_d' }
      return 'img/rc/' + race.toLowerCase() + '.jpg';
    },
    'img.pw': function(power, in_decline) {
      if (is_null(power)) { power = 'nobody' }
      if (in_decline) { power += '_d' }
      return 'img/pw/' + power.toLowerCase() + '.jpg';
    },
    'js': 'js',
    'css': 'css'
  };

  return storage[type];
}
