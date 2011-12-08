package Game::Constants;
use warnings;
use strict;
use Game::Environment 'is_debug';
use Exporter::Easy (
    OK => [ qw(races
               races_with_debug
               powers
               powers_with_debug) ] );

our @races = qw(
amazons
dwarves
elves
giants
halflings
humans
orcs
ratmen
skeletons
sorcerers
tritons
trolls
wizards
);

our @races_with_debug = (@races, 'debug');

our @powers = qw(
alchemist
berserk
bivouacking
commando
diplomat
dragonMaster
flying
forest
fortified
heroic
hill
merchant
mounted
pillaging
seafaring
stout
swamp
underworld
wealthy
);

our @powers_with_debug = (@powers, 'debug');

sub races {
    \@races
}

sub powers {
    \@powers
}

sub races_with_debug {
    \@races_with_debug
}

sub powers_with_debug {
    \@powers_with_debug
}
