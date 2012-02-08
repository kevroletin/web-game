use Test::Harness;

{
    runtests('t/game/race_selected.t',
             (map { "t/races/$_.t" } qw(amazons
                                      dwarves
                                      elves
                                      giants
                                      halflings
                                      humans
                                      orcs
                                      ratmens
                                      skeletons
                                      sorcerers
                                      tritons
                                      trolls
                                      wizards)),
             (map { "t/powers/$_.t" } qw(alchemist
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
                                       wealthy))
            );
}

1;
