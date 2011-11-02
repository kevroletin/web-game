package Game::Constants::Map;
use warnings;
use strict;

use Game::Model::Region;

=begin comment

my $m1 = {
  mapName => "defaultMap1",
  playersNum => 2,
  turnsNum => 5,
  regions => []
};

my $m2 = {
  mapName => "defaultMap2",
  playersNum => 3,
  turnsNum => 5,
  regions => undef
};

my $m3 = {
  mapName => "defaultMap3",
  playersNum => 4,
  turnsNum => 5,
  regions => undef
};

my $m4 = {
  mapName => "defaultMap4",
  playersNum => 5,
  turnsNum => 5,
  regions => undef
};

my $m5 = {
  mapName => "defaultMap5",
  playersNum => 2,
  regions => [ map { Game::Model::Region->new($_) }
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
  regions => [ map { Game::Model::Region->new($_) }
    {
      adjacent => [ 1, 6, 7 ],
      landDescription => [
        "sea",
        "border"
      ]
    },
    {
      adjacent => [ 0, 7, 8, 2 ],
      landDescription => [
        "mine",
        "border",
        "coast",
        "forest"
      ]
    },
    {
      adjacent => [ 1, 8, 0, 3 ],
      landDescription => [
        "border",
        "mountain"
      ]
    },
    {
      adjacent => [ 2, 0, 1, 4 ],
      landDescription => [
        "farmland",
        "border"
      ]
    },
    {
      adjacent => [ 3, 1, 2, 5 ],
      landDescription => [
        "cavern",
        "border",
        "swamp"
      ]
    },
    {
      adjacent => [ 4, 2, 6 ],
      landDescription => [
        "forest",
        "border"
      ],
      population => 1
    },
    {
      adjacent => [ 5, 2, 7, 3, 5 ],
      landDescription => [
        "mine",
        "border",
        "swamp"
      ]
    },
    {
      adjacent => [ 6, 5, 9, 8, 3 ],
      landDescription => [
        "border",
        "mountain",
        "coast"
      ]
    },
    {
      adjacent => [ 7, 9, 0 ],
      landDescription => [
        "border",
        "sea"
      ]
    },
    {
      adjacent => [ 8, 7, 0, 5 ],
      landDescription => [
        "cavern",
        "coast"
      ],
      population => 1
    },
    {
      adjacent => [ 9, 5, 6, 1 ],
      landDescription => [
        "mine",
        "coast",
        "forest",
        "border"
      ],
      population => 1
    },
    {
      adjacent => [ 0, 6, 9, 2 ],
      landDescription => [
        "forest",
        "border"
      ]
    },
    {
      adjacent => [ 1, 9, 7, 3 ],
      landDescription => [
        "mountain",
        "border"
      ]
    },
    {
      adjacent => [ 2, 7, 5, 4 ],
      landDescription => [
        "mountain",
        "border"
      ]
    },
    {
      adjacent => [ 3, 5 ],
      landDescription => [
        "hill",
        "border"
      ]
    },
    {
      adjacent => [ 4, 9, 7, 6 ],
      landDescription => [
        "farmland",
        "magic",
        "border"
      ]
    },
    {
      adjacent => [ 5, 9, 0, 7 ],
      landDescription => [
        "border",
        "mountain",
        "cavern",
        "mine",
        "coast"
      ]
    },
    {
      adjacent => [ 6, 9, 0, 8 ],
      landDescription => [
        "farmland",
        "magic",
        "coast"
      ],
      population => 1
    },
    {
      adjacent => [ 7, 2, 0, 1, 9 ],
      landDescription => [
        "swamp"
      ]
    },
    {
      adjacent => [ 8, 7, 8, 0 ],
      landDescription => [
        "swamp"
      ],
      population => 1
    },
    {
      adjacent => [ 9, 8, 2, 3, 1 ],
      landDescription => [
        "hill",
        "magic"
      ],
      population => 1
    },
    {
      adjacent => [ 0, 4, 8, 3, 4, 2 ],
      landDescription => [
        "mountain",
        "mine"
      ]
    },
    {
      adjacent => [ 1, 4, 5, 4, 3 ],
      landDescription => [
        "farmland"
      ],
      population => 1
    },
    {
      adjacent => [ 2, 5, 6, 4, 7 ],
      landDescription => [
        "hill",
        "magic"
      ]
    },
    {
      adjacent => [ 3, 1, 2, 8 ],
      landDescription => [
        "mountain",
        "cavern"
      ]
    },
    {
      adjacent => [ 4, 3, 6, 7, 9, 0, 6 ],
      landDescription => [
        "farmland"
      ],
      population => 1
    },
    {
      adjacent => [ 5, 0, 1, 9, 8 ],
      landDescription => [
        "swamp",
        "magic"
      ],
      population => 1
    },
    {
      adjacent => [ 8, 9, 2, 3, 5, 9 ],
      landDescription => [
        "forest",
        "cavern"
      ],
      population => 1
    },
    {
      adjacent => [ 7, 9, 0, 1, 4, 6, 9 ],
      landDescription => [
        "sea"
      ]
    },
    {
      adjacent => [ 8, 7, 2, 1, 6 ],
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
  regions => [ map { Game::Model::Region->new($_) }
    {
      adjacent => [ 2 ],
      landDescription => [
        "border",
        "mountain"
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
        "mountain"
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
        "mountain"
      ]
    }
  ],
  turnsNum => 5
};

=cut comment

our @maps = ();#$m1, $m2, $m3, $m4, $m5, $m6, $m7);

1
