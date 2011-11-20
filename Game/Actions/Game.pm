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
                               leaveGame
                               getGameState
                               getGameList
                               leaveGame
                               setReadinessStatus)] );
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
    db()->store_nonroot($game);
    response_json({ result => 'ok', gameId => $game->gameId() });
}

sub getGameState {
    my ($data) = @_;
    my $game;
    unless (defined $data->{gameId}) {
        $game = global_game()
    } else {
        $game = db_search_one({ gameId => $data->{gameId} },
                              { CLASS => 'Game::Model::Game' });
        unless ($game) {
            early_response_json({result => 'badGameId'})
        }
    }

    my $state = $game->extract_state();
    $state->{result} = 'ok';
    response_json($state)
}

sub getGameList {
    my @q = db_search({ CLASS => 'Game::Model::Game' })->all();
    my @games = map { $_->short_info() } @q;
    response_json({result => 'ok', games => \@games});
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
    if ($game->state() ne 'notStarted') {
        early_response_json({ result => 'badGameState' })
    }

    if (@{$game->players()} eq $game->map()->playersNum()) {
        early_response_json({ result => 'tooManyPlayers' })
    }

    global_user()->activeGame($game);
    $game->add_player(global_user());

    db()->update(global_user(), $game);
    response_json({result => 'ok'})
}

sub leaveGame {
    my ($data) = @_;

    my $game = global_game();
    $game->remove_player(global_user());
    global_user()->activeGame(undef);

    db()->update(global_user(), $game);
    response_json({result => 'ok'});
}

sub setReadinessStatus {
    my ($data) = @_;
    proto($data, 'isReady');

    my $game = global_game();
    unless ($game->state() eq 'notStarted') {
        early_response_json({result => 'badGameStage'})
    }

    global_user()->readinessStatus($data->{isReady});
    if ($game->ready()) {
        $game->state('startMoving');
    }

    db()->update(global_user(), $game);
    response_json({result => 'ok'})
}

# TODO:
# getGameState

# TODO:
# getMapState

# TODO:
# saveGame

# TODO:
# loadGame

1
