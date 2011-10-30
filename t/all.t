use Test::Harness;

{
    runtests("lobby/basic.t",
             "lobby/complicated.t",
             "game_creation.t",
#             "gameplay.t",
             map { "races/$_.t" } qw(dwarves
                                     humans
                                     ratmens
                                     wizards));
}

1;
