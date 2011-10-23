use Game::Actions::Game;
use strict;
use warnings;

use Game::Actions;
use Game::Environment qw(db db_search db_search_one
                         early_response_json
                         global_game
                         global_user
                         response response_json);
use Game::Model::Game;
use Exporter::Easy ( OK => [qw(createGame
                               joinGame
                               leaveGame)] );
use KiokuDB::Set;


sub createGame {
    my ($data) = @_;
    proto($data, 'gameName', 'mapId');

    if (db_search_one({ gameName => $data->{gameName} },
                      { CLASS => 'Game::Model::Game' }))
    {
        early_response_json({result => 'gameNameTaken'});
    }

    my $map = db_search_one({ id => $data->{mapId} },
                            { CLASS => 'Game::Model::Map' });
    unless ($map) {
        early_response_json({result => 'badMapId'});
    }

    my $game = Game::Model::Game->new(
                   params_from_proto('gameName', 'gameDescr'),
                   map => $map
               );
    db()->store($game);
    response_json({ result => 'ok', gameId => $game->gameId() });
}

sub joinGame {
    my ($data) = @_;
    proto($data, 'gameId');

    my $game = db_search_one({ gameId => $data->{gameId} },
                             { CLASS => 'Game::Model::Game' });


    unless ($game) {
        early_response_json({ result => 'badGameId' })
    }
    if (defined global_user()->activeGame()) {
        early_response_json({ result => 'alreadyInGame' })
    }
    if ($game->state() ne 'waitingTheBeginning') {
        early_response_json({ result => 'badGameState' })
    }

    if (@{$game->players()} eq $game->map()->playersNum()) {
        early_response_json({ result => 'tooManyPlayers' })
    }

    global_user()->activeGame($game);
    $game->add_player(global_user());

    db()->store(global_user(), $game);
    response_json({result => 'ok'})
}

sub leaveGame {
    my ($data) = @_;

    my $game = global_game();
    $game->remove_player(global_user());
    global_user()->activeGame(undef);

    db()->store(global_user(), $game);
    response_json({result => 'ok'});
}

sub setReadinessStatus {
    my ($data) = @_;
    proto($data, 'readinessStatus');

    my $game = global_user()->activeGame();
    unless (defined $game) {
        early_response_json({result => 'notInGame'})
    }
    unless ($game->state() eq 'waitingTheBeginning') {
        early_response_json({result => 'badGameState'})
    }

    global_user()->readinessStatus($data->{readinessStatus});
    if ($game->ready()) {
        $game->state('processing');
    }

    db()->store(global_user(), $game);
    response_json({result => 'ok'})
}

# TODO:
# getGameList

# TODO:
# getGameState

# TODO:
# getMapState

# TODO:
# saveGame

# TODO:
# loadGame

1
