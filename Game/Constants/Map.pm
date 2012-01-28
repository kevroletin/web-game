package Game::Constants::Map;
use warnings;
use strict;
use Game::Model::Region;

my $m5 = {
  mapName => "defaultMap5",
  playersNum => 2,
  regions => [
    {
      adjacent => [ 3, 4 ],
      landDescription => [
        "mountain"
      ],
      population => 1
    },
    {
      adjacent => [ 1, 4 ],
      landDescription => [
        "sea"
      ],
      population => 1
    },
    {
      adjacent => [ 1 ],
      landDescription => [
        "border",
        "mountain"
      ],
      population => 1
    },
    {
      adjacent => [ 1, 2 ],
      landDescription => [
        "coast"
      ],
      population => 1
    }
  ],
  turnsNum => 5
};

my $m6 = {
  mapName => "defaultMap6",
  playersNum => 2,
  regions => [
    {
      adjacent => [ 2, 17, 18 ],
      landDescription => [
        "sea",
        "border"
      ]
    },
    {
      adjacent => [ 1, 18, 19, 3 ],
      landDescription => [
        "mine",
        "border",
        "coast",
        "forest"
      ]
    },
    {
      adjacent => [ 2, 19, 21, 4 ],
      landDescription => [
        "border",
        "mountain"
      ]
    },
    {
      adjacent => [ 3, 21, 22, 5 ],
      landDescription => [
        "farmland",
        "border"
      ]
    },
    {
      adjacent => [ 4, 22, 23, 6 ],
      landDescription => [
        "cavern",
        "border",
        "swamp"
      ]
    },
    {
      adjacent => [ 5, 23, 7 ],
      landDescription => [
        "forest",
        "border"
      ],
      population => 1
    },
    {
      adjacent => [ 6, 23, 8, 24, 26 ],
      landDescription => [
        "mine",
        "border",
        "swamp"
      ]
    },
    {
      adjacent => [ 7, 26, 10, 9, 24 ],
      landDescription => [
        "border",
        "mountain",
        "coast"
      ]
    },
    {
      adjacent => [ 8, 10, 11 ],
      landDescription => [
        "border",
        "sea"
      ]
    },
    {
      adjacent => [ 9, 8, 11, 26 ],
      landDescription => [
        "cavern",
        "coast"
      ],
      population => 1
    },
    {
      adjacent => [ 10, 26, 27, 12 ],
      landDescription => [
        "mine",
        "coast",
        "forest",
        "border"
      ],
      population => 1
    },
    {
      adjacent => [ 11, 27, 30, 13 ],
      landDescription => [
        "forest",
        "border"
      ]
    },
    {
      adjacent => [ 12, 30, 28, 14 ],
      landDescription => [
        "mountain",
        "border"
      ]
    },
    {
      adjacent => [ 13, 28, 16, 15 ],
      landDescription => [
        "mountain",
        "border"
      ]
    },
    {
      adjacent => [ 14, 16 ],
      landDescription => [
        "hill",
        "border"
      ]
    },
    {
      adjacent => [ 15, 20, 28, 17 ],
      landDescription => [
        "farmland",
        "magic",
        "border"
      ]
    },
    {
      adjacent => [ 16, 20, 1, 18 ],
      landDescription => [
        "border",
        "mountain",
        "cavern",
        "mine",
        "coast"
      ]
    },
    {
      adjacent => [ 17, 20, 1, 19 ],
      landDescription => [
        "farmland",
        "magic",
        "coast"
      ],
      population => 1
    },
    {
      adjacent => [ 18, 3, 21, 2, 20 ],
      landDescription => [
        "swamp"
      ]
    },
    {
      adjacent => [ 19, 28, 29, 21 ],
      landDescription => [
        "swamp"
      ],
      population => 1
    },
    {
      adjacent => [ 20, 29, 3, 4, 22 ],
      landDescription => [
        "hill",
        "magic"
      ],
      population => 1
    },
    {
      adjacent => [ 21, 25, 29, 4, 5, 23 ],
      landDescription => [
        "mountain",
        "mine"
      ]
    },
    {
      adjacent => [ 22, 25, 6, 5, 24 ],
      landDescription => [
        "farmland"
      ],
      population => 1
    },
    {
      adjacent => [ 23, 26, 7, 25, 8 ],
      landDescription => [
        "hill",
        "magic"
      ]
    },
    {
      adjacent => [ 24, 22, 23, 29 ],
      landDescription => [
        "mountain",
        "cavern"
      ]
    },
    {
      adjacent => [ 25, 24, 7, 8, 10, 11, 27 ],
      landDescription => [
        "farmland"
      ]
    },
    {
      adjacent => [ 26, 11, 12, 30, 29 ],
      landDescription => [
        "swamp",
        "magic"
      ],
      population => 1
    },
    {
      adjacent => [ 29, 30, 13, 14, 16, 20 ],
      landDescription => [
        "forest",
        "cavern"
      ],
      population => 1
    },
    {
      adjacent => [ 28, 20, 21, 22, 25, 27, 30 ],
      landDescription => [
        "sea"
      ]
    },
    {
      adjacent => [ 29, 28, 13, 12, 27 ],
      landDescription => [
        "hill"
      ]
    }
  ],
  turnsNum => 7
};

my $m7 = {
  mapName => "defaultMap7",
  playersNum => 2,
  regions => [
    {
      adjacent => [ 2 ],
      landDescription => [
        "border",
        "mountain",
        "mine",
        "farmland",
        "magic"
      ]
    },
    {
      adjacent => [ 1, 3 ],
      landDescription => [
        "mountain"
      ]
    },
    {
      adjacent => [ 2, 4 ],
      landDescription => [
        "mountain",
        "mine"
      ],
      population => 1
    },
    {
      adjacent => [ 3, 5 ],
      landDescription => [
        "mountain"
      ],
      population => 1
    },
    {
      adjacent => [ 4 ],
      landDescription => [
        "mountain",
        "mine"
      ]
    }
  ],
  turnsNum => 5
};

my $m8 = {
  action => "uploadMap",
  mapName => "map1",
  playersNum => 2,
  regions => [
    {
      adjacent => [ 2, 6 ],
      coordinates => [
        [ 0, 0 ],
        [ 0, 158 ],
        [ 46, 146 ],
        [ 126, 151 ],
        [ 104, 0 ]
      ],
      landDescription => [
        "border",
        "coast",
        "magic",
        "forest"
      ],
      powerCoords => [ 64, 97 ],
      raceCoords => [ 15, 15 ],
      magicCoords => [ 40, 20 ]
    },
    {
      adjacent => [ 1, 3, 6, 7 ],
      coordinates => [
        [ 104, 0 ],
        [ 126, 151 ],
        [ 154, 135 ],
        [ 202, 107 ],
        [ 258, 104 ],
        [ 277, 77 ],
        [ 264, 0 ]
      ],
      landDescription => [
        "border",
        "coast",
        "sea"
      ],
      powerCoords => [ 130, 64 ],
      raceCoords => [ 130, 8 ]
    },
    {
      adjacent => [ 2, 4, 7, 8 ],
      coordinates => [
        [ 264, 0 ],
        [ 277, 77 ],
        [ 258, 104 ],
        [ 273, 142 ],
        [ 297, 143 ],
        [ 392, 113 ],
        [ 409, 95 ],
        [ 393, 45 ],
        [ 404, 0 ]
      ],
      landDescription => [
        "border",
        "coast",
        "magic",
        "farmland"
      ],
      powerCoords => [ 317, 65 ],
      raceCoords => [ 285, 8 ],
      magicCoords => [ 340, 20 ]
    },
    {
      adjacent => [ 3, 5, 8, 9, 10 ],
      coordinates => [
        [ 404, 0 ],
        [ 393, 45 ],
        [ 409, 95 ],
        [ 392, 113 ],
        [ 422, 179 ],
        [ 508, 160 ],
        [ 536, 106 ],
        [ 503, 82 ],
        [ 551, 36 ],
        [ 552, 0 ]
      ],
      landDescription => [
        "border",
        "coast",
        "mine",
        "forest"
      ],
      population => 1,
      powerCoords => [ 419, 65 ],
      raceCoords => [ 412, 8 ],
      mineCoords => [ 480, 8 ]
    },
    {
      adjacent => [ 4, 10 ],
      coordinates => [
        [ 552, 0 ],
        [ 551, 36 ],
        [ 503, 82 ],
        [ 536, 106 ],
        [ 630, 123 ],
        [ 630, 0 ]
      ],
      landDescription => [
        "border",
        "swamp",
        "cavern"
      ],
      powerCoords => [ 570, 55 ],
      raceCoords => [ 560, 4 ],
      cavernCoords => [ 560, 60 ]
    },
    {
      adjacent => [ 1, 2, 7, 11 ],
      coordinates => [
        [ 0, 158 ],
        [ 46, 146 ],
        [ 126, 151 ],
        [ 154, 135 ],
        [ 132, 256 ],
        [ 92, 233 ],
        [ 0, 282 ]
      ],
      landDescription => [
        "border",
        "coast",
        "hill"
      ],
      powerCoords => [ 6, 195 ],
      raceCoords => [ 63, 165 ]
    },
    {
      adjacent => [ 2, 3, 6, 8, 11, 12 ],
      coordinates => [
        [ 154, 135 ],
        [ 202, 107 ],
        [ 258, 104 ],
        [ 273, 142 ],
        [ 297, 143 ],
        [ 305, 172 ],
        [ 268, 222 ],
        [ 191, 247 ],
        [ 132, 256 ]
      ],
      landDescription => [
        "mountain",
        "border",
        "coast",
        "mine",
        "mountain",
        "cavern"
      ],
      powerCoords => [ 167, 135 ],
      raceCoords => [ 150, 190 ],
      mineCoords => [ 170, 190 ],
      cavernCoords => [ 170, 130 ]
    },
    {
      adjacent => [ 3, 4, 7, 9, 12, 13 ],
      coordinates => [
        [ 297, 143 ],
        [ 392, 113 ],
        [ 444, 235 ],
        [ 388, 277 ],
        [ 350, 247 ],
        [ 308, 254 ],
        [ 268, 222 ],
        [ 305, 172 ]
      ],
      landDescription => [
        "coast",
        "hill"
      ],
      population => 1,
      powerCoords => [ 333, 137 ],
      raceCoords => [ 300, 191 ]
    },
    {
      adjacent => [ 4, 8, 10, 13, 14 ],
      coordinates => [
        [ 422, 179 ],
        [ 508, 160 ],
        [ 548, 238 ],
        [ 565, 276 ],
        [ 508, 317 ],
        [ 388, 277 ],
        [ 444, 235 ]
      ],
      landDescription => [
        "sea"
      ],
      powerCoords => [ 453, 180 ],
      raceCoords => [ 448, 240 ]
    },
    {
      adjacent => [ 4, 5, 9, 14 ],
      coordinates => [
        [ 508, 160 ],
        [ 536, 106 ],
        [ 630, 123 ],
        [ 630, 242 ],
        [ 548, 238 ]
      ],
      landDescription => [
        "border",
        "coast",
        "mountain"
      ],
      population => 1,
      powerCoords => [ 536, 123 ],
      raceCoords => [ 546, 180 ]
    },
    {
      adjacent => [ 6, 7, 12, 15 ],
      coordinates => [
        [ 0, 377 ],
        [ 114, 343 ],
        [ 155, 342 ],
        [ 160, 255 ],
        [ 132, 256 ],
        [ 92, 233 ],
        [ 0, 282 ]
      ],
      landDescription => [
        "border",
        "sea"
      ],
      powerCoords => [ 65, 253 ],
      raceCoords => [ 7, 305 ]
    },
    {
      adjacent => [ 7, 8, 11, 13, 15, 17 ],
      coordinates => [
        [ 217, 339 ],
        [ 281, 331 ],
        [ 312, 290 ],
        [ 308, 254 ],
        [ 268, 222 ],
        [ 191, 247 ],
        [ 160, 255 ],
        [ 155, 342 ]
      ],
      landDescription => [
        "coast",
        "farmland"
      ],
      powerCoords => [ 163, 287 ],
      raceCoords => [ 214, 253 ]
    },
    {
      adjacent => [ 8, 9, 12, 14, 17, 18, 19 ],
      coordinates => [
        [ 308, 254 ],
        [ 350, 247 ],
        [ 388, 277 ],
        [ 508, 317 ],
        [ 511, 374 ],
        [ 404, 411 ],
        [ 281, 331 ],
        [ 312, 290 ]
      ],
      landDescription => [
        "coast",
        "forest"
      ],
      population => 1,
      powerCoords => [ 318, 295 ],
      raceCoords => [ 380, 313 ]
    },
    {
      adjacent => [ 9, 10, 13, 19, 20 ],
      coordinates => [
        [ 508, 317 ],
        [ 565, 276 ],
        [ 548, 238 ],
        [ 630, 242 ],
        [ 630, 418 ],
        [ 553, 416 ],
        [ 511, 374 ]
      ],
      landDescription => [
        "border",
        "coast",
        "magic",
        "farmland"
      ],
      powerCoords => [ 565, 287 ],
      raceCoords => [ 546, 348 ],
      magicCoords => [ 530, 300 ]
    },
    {
      adjacent => [ 11, 12, 16, 17 ],
      coordinates => [
        [ 0, 377 ],
        [ 114, 343 ],
        [ 155, 342 ],
        [ 217, 339 ],
        [ 247, 387 ],
        [ 185, 465 ],
        [ 0, 426 ]
      ],
      landDescription => [
        "border",
        "coast",
        "magic",
        "swamp"
      ],
      population => 1,
      powerCoords => [ 28, 376 ],
      raceCoords => [ 87, 375 ],
      magicCoords => [ 20, 376 ]
    },
    {
      adjacent => [ 15, 17 ],
      bonusCoords => [ 129, 483 ],
      coordinates => [
        [ 0, 426 ],
        [ 185, 465 ],
        [ 186, 515 ],
        [ 0, 515 ]
      ],
      landDescription => [
        "border",
        "hill",
        "cavern"
      ],
      population => 1,
      powerCoords => [ 6, 458 ],
      raceCoords => [ 62, 458 ],
      cavernCoords => [ 140, 450 ]
    },
    {
      adjacent => [ 12, 13, 15, 16, 18 ],
      coordinates => [
        [ 186, 515 ],
        [ 288, 515 ],
        [ 336, 369 ],
        [ 281, 331 ],
        [ 217, 339 ],
        [ 247, 387 ],
        [ 185, 465 ]
      ],
      landDescription => [
        "border",
        "mountain",
        "mine"
      ],
      powerCoords => [ 244, 398 ],
      raceCoords => [ 202, 460 ],
      mineCoords => [ 220, 460 ]
    },
    {
      adjacent => [ 13, 17, 19 ],
      coordinates => [
        [ 288, 515 ],
        [ 336, 369 ],
        [ 404, 411 ],
        [ 408, 513 ]
      ],
      landDescription => [
        "border",
        "cavern",
        "hill"
      ],
      powerCoords => [ 308, 464 ],
      raceCoords => [ 324, 411 ],
      cavernCoords => [ 324, 380 ]
    },
    {
      adjacent => [ 13, 14, 18, 20 ],
      bonusCoords => [ 514, 418 ],
      coordinates => [
        [ 404, 411 ],
        [ 511, 374 ],
        [ 553, 416 ],
        [ 519, 471 ],
        [ 520, 515 ],
        [ 408, 513 ]
      ],
      landDescription => [
        "border",
        "mine",
        "swamp"
      ],
      population => 1,
      powerCoords => [ 437, 466 ],
      raceCoords => [ 419, 411 ],
      mineCoords => [ 480, 411 ]
    },
    {
      adjacent => [ 14, 19 ],
      coordinates => [
        [ 520, 515 ],
        [ 630, 515 ],
        [ 630, 418 ],
        [ 553, 416 ],
        [ 519, 471 ]
      ],
      landDescription => [
        "border",
        "mountain"
      ],
      powerCoords => [ 582, 422 ],
      raceCoords => [ 529, 466 ]
    }
  ],
  turnsNum => 10
};

sub stub_map {
    my $name = shift;
    my $num = shift;
    my $turnsNum = shift;
    return {
            action => "uploadMap",
            mapName => $name,
            playersNum => $num,
            regions => [],
            turnsNum => $turnsNum
           };
};

our @maps_lena = (
             stub_map('defaultMap1', 2, 5),
             stub_map('defaultMap2', 3, 5),
             stub_map('defaultMap3', 4, 5),
             stub_map('defaultMap4', 5, 5),
             $m5, $m6, $m7, $m8
            );

our @maps = (
  {picture=>"/public/imgs/map_1.png", mapName => 'Are you lucky?', playersNum => 2, turnsNum => 5, regions =>[
    {
      population  => 1, landDescription => ['border', 'coast'], adjacent => [2],
      coordinates => [ [0,0], [300,0], [300,399], [0,399] ],
      raceCoords  => [164,117],
      powerCoords => [172,292]
    },
    {
      population  => 0, landDescription => ['border'], adjacent => [1],
      coordinates => [ [300,0], [300,399], [639,399], [639,0] ],
      raceCoords  => [502,199],
      powerCoords => [493,287]
    },
  ]},
  {picture=>"/public/imgs/map_2.png", mapName => 'Cheburashka', playersNum => 3, turnsNum => 5, regions => [
    {
      population  => 1, landDescription => ['mountain'], adjacent => [2, 3, 4],
      coordinates => [ [255,290], [234,254], [224,213], [239,168], [287,137], [355,135], [395,178], [398, 234], [371,284], [304,279] ],
      raceCoords  => [267,180],
      powerCoords => [346,173]
    },
    {
      population  => 1, landDescription => ['sea'], adjacent => [1, 4],
      coordinates => [ [224,213], [175,217], [132,184], [113,136], [131,91], [185,69], [242,77], [272,108], [287,137], [239,168] ],
      raceCoords  => [143,100],
      powerCoords => [218,82]
    },
    {
      population  => 1, landDescription => ['border', 'mountain'], adjacent => [1],
      coordinates => [ [269,399], [249,385], [232,360], [230,337], [236,305], [255,290], [304,279], [371,284], [405,303], [418,330], [411,356], [405,387], [396,399] ],
      raceCoords  => [297,316],
      powerCoords => [363,310]
    },
    {
      population  => 1, landDescription => ['coast'], adjacent => [1, 2],
      coordinates => [ [355,135], [365,96], [400,69], [446,62], [505,86], [523,138], [515,187], [487,218], [442,233], [398,234], [395,178] ],
      raceCoords  => [400,75],
      powerCoords => [465,137]
    }
  ]},
{
  'mapName' => 'map1',
  'playersNum' => 2,
  'turnsNum' => 10,
  'regions' => [
    {
      'landDescription' => ['border', 'coast', 'magic', 'forest'],     #1
      'coordinates' => [[0, 0], [0, 158], [46, 146], [126, 151], [104, 0]],
      'adjacent' => [2, 6],
      'raceCoords' => [15, 15],
      'powerCoords' => [64, 97]
    },

    {
      'landDescription' => ['border', 'coast', 'sea'],       #2
      'coordinates' => [[104, 0], [126, 151], [154, 135], [202, 107], [258, 104], [277, 77], [264, 0]],
      'adjacent' => [1, 3, 6, 7],
      'raceCoords' => [130, 8],
      'powerCoords' => [130, 64]
    },

    {
      'landDescription' => ['border', 'coast', 'magic', 'farmland'],         #3
      'coordinates' => [[264, 0], [277, 77], [258, 104], [273, 142], [297, 143], [392, 113], [409, 95], [393, 45], [404, 0]],
      'adjacent' => [2, 4, 7, 8],
      'raceCoords' => [285, 8],
      'powerCoords' => [317, 65]
    },

    {
      'population' => 1,
      'landDescription' => ['border', 'coast', 'mine', 'forest'],      #4
      'adjacent' => [3, 5, 8, 9, 10],
      'coordinates' => [[404, 0], [393, 45], [409, 95], [392, 113], [422, 179], [508, 160], [536, 106], [503, 82], [551, 36], [552, 0]],
      'raceCoords' => [412, 8],
      'powerCoords' => [419, 65]
    },

    {
      'landDescription' => ['border', 'swamp', 'cavern'],          #5
      'coordinates' => [[552, 0],  [551, 36], [503, 82], [536, 106], [630, 123], [630, 0]],
      'adjacent' => [4, 10],
      'raceCoords' => [560, 4],
      'powerCoords' => [570, 55],
    },
    {
      'landDescription' => ['border', 'coast', 'hill'],          #6
      'coordinates' => [[0, 158], [46, 146], [126, 151], [154, 135], [132, 256], [92, 233], [0, 282]],
      'adjacent' => [1, 2, 7, 11],
      'raceCoords' => [63, 165],
      'powerCoords' => [6, 195]
    },

    {                                   #7
      'landDescription' => ['mountain', 'border', 'coast', 'mine', 'mountain', 'cavern'],
      'adjacent' => [2, 3, 6, 8, 11, 12],
      'coordinates' => [[154, 135], [202, 107], [258, 104], [273, 142], [297, 143], [305, 172], [268, 222], [191, 247], [132, 256]],
      'raceCoords' => [150, 190],
      'powerCoords' => [167, 135],
    },


    {
      'population' => 1,
      'landDescription' => ['coast', 'hill'],              #8
      'adjacent' => [3, 4, 7, 9, 12, 13],
      'coordinates' => [[297, 143], [392, 113], [444, 235], [388, 277], [350, 247], [308, 254], [268, 222], [305, 172]],
      'raceCoords' => [300, 191],
      'powerCoords' => [333, 137],
    },


    {                                   #9
      'landDescription' => ['sea'],
      'coordinates' => [[422, 179], [508, 160], [548, 238], [565, 276], [508, 317], [388, 277], [444, 235]],
      'adjacent' => [4, 8, 10, 13, 14],
      'raceCoords' => [448, 240],
      'powerCoords' => [453, 180]
    },

    {                                   #10
      'landDescription' => ['border', 'coast', 'mountain'],
      'population' => 1,
      'adjacent' => [4, 5, 9, 14],
      'coordinates' => [[508, 160],  [536, 106], [630, 123], [630, 242], [548, 238]],
      'raceCoords' => [546, 180],
      'powerCoords' => [536, 123]
    },

    {                                   #11
      'landDescription' => ['border', 'sea'],
      'adjacent' => [6, 7, 12, 15],
      'coordinates' => [[0, 377], [114, 343], [155, 342], [160, 255], [132, 256], [92, 233], [0, 282]],
      'raceCoords' => [7, 305],
      'powerCoords' => [65, 253]
    },

    {                                   #12
      'landDescription' => ['coast', 'farmland'],
      'coordinates' => [[217, 339], [281, 331], [312, 290], [308, 254], [268, 222], [191, 247], [160, 255], [155, 342]],
      'adjacent' => [7, 8, 11, 13, 15, 17],
      'raceCoords' => [214, 253],
      'powerCoords' => [163, 287]
    },

    {                                   #13
      'landDescription' => ['coast', 'forest'],
      'population' => 1,
      'coordinates' => [[308, 254], [350, 247], [388, 277], [508, 317], [511, 374],  [404, 411], [281, 331], [312, 290]],
      'adjacent' => [8, 9, 12, 14, 17, 18, 19],
      'raceCoords' => [380, 313],
      'powerCoords' => [318, 295]
    },


    {
      'landDescription' => ['border', 'coast', 'magic', 'farmland'],   #14
      'coordinates' => [[508, 317], [565, 276], [548, 238], [630, 242], [630, 418], [553, 416], [511, 374]],
      'adjacent' => [9, 10, 13, 19, 20],
      'raceCoords' => [546, 348],
      'powerCoords' => [565, 287]

    },

    {                                   #15
      'landDescription' => ['border', 'coast', 'magic', 'swamp'],
      'population' => 1,
      'adjacent' => [11, 12, 16, 17],
      'coordinates' => [[0, 377], [114, 343], [155, 342],[217, 339], [247, 387], [185, 465], [0, 426]],
      'raceCoords' => [87, 375],
      'powerCoords' => [28, 376]
    },

    {
      'landDescription' => ['border', 'hill', 'cavern'],         #16
      'coordinates' => [[0, 426], [185, 465], [186, 515], [0, 515]],
      'population' => 1,
      'bonusCoords' => [129, 483],
      'raceCoords' => [62, 458],
      'powerCoords' => [6, 458],
      'adjacent' => [15, 17]
    },

    {                                   #17
      'landDescription' => ['border', 'mountain', 'mine'],
      'adjacent' => [12, 13, 15, 16, 18],
      'coordinates' => [[186, 515], [288, 515], [336, 369], [281, 331], [217, 339], [247, 387], [185, 465]],
      'raceCoords' => [202, 460],
      'powerCoords' => [244, 398]
    },

    {                                   #18
      'landDescription' => ['border', 'cavern', 'hill'],
      'coordinates' => [[288, 515], [336, 369], [404, 411], [408, 513]],
      'adjacent' => [13, 17, 19],
      'raceCoords' => [324, 411],
      'powerCoords' => [308, 464]
    },

    {                                   #19
      'landDescription' => ['border', 'mine', 'swamp'],
      'population' => 1,
      'coordinates' => [[404, 411], [511, 374], [553, 416], [519, 471], [520, 515], [408, 513]],
      'adjacent' => [13, 14, 18, 20],
      'bonusCoords' => [514, 418],
      'raceCoords' => [419, 411],
      'powerCoords' => [437, 466]
    },

    {                                   #20
      'landDescription' => ['border', 'mountain'],
      'coordinates' => [[520, 515], [630, 515], [630, 418], [553, 416], [519, 471]],
      'adjacent' => [14, 19],
      'raceCoords' => [529, 466],
      'powerCoords' => [582, 422]
    }
  ]
}
);


1
