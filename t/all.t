use Test::Harness;

{
    runtests("lobby/basic.t",
             "lobby/complicated.t",
#             "game_creation.t", #TODO: fix default maps
#             "gameplay.t",
             (map { "races/$_.t" } qw(amazons
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
             (map { "powers/$_.t" } qw(alchemist
                                       berserk
                                       diplomat
                                       dragonMaster
                                       forest
                                       fortified
                                       bivouacking)));
}

1;
