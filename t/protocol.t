use Test::Harness;

{
    runtests(
#             "t/lobby/basic.t",
             't/lobby/complicated.t',
             't/game/stage.t'
#             "game_creation.t", #TODO: fix default maps
#             "gameplay.t",
             );
}

1;
