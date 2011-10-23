use Test::Harness;

{
    runtests("lobby/basic.t",
             "lobby/complicated.t",
             "game_creation.t",
             "gameplay.t");
}

1;
