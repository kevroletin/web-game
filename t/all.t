use Test::Harness;

{
    runtests("lobby/basic.t",
             "lobby/complicated.t",
#             "game_creation.t", #TODO: fix default maps
#             "gameplay.t",
             map { "races/$_.t" } qw(amazons
                                     dwarves
                                     elves
                                     giants
                                     humans
                                     orcs
                                     ratmens
                                     skeletons
                                     tritons
                                     wizards));
}

1;
