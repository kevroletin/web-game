use Test::Harness;

{
    runtests("lobby/basic.t",
             "lobby/complicated.t",
#             "game_creation.t", #TODO: fix default maps
#             "gameplay.t",
             map { "races/$_.t" } qw(dwarves
                                     humans
                                     ratmens
                                     wizards));
}

1;
