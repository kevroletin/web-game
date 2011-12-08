use Game::Actions::Game;
use strict;
use warnings;

use Game::Actions;
use Game::Environment qw(assert db db_search db_search_one
                         early_response_json
                         init_user_by_sid
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
                               loadGame
                               setReadinessStatus)] );

sub _construct_new_game {
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
    $game
}

sub createGame {
    my ($data) = @_;

    my $game = _construct_new_game($data);

    db()->store_nonroot($game);
    response_json({ result => 'ok', gameId => $game->gameId() });
}

sub _get_game_by_id {
    my ($id) = @_;
    my $game = db_search_one({ gameId => $id },
                             { CLASS => 'Game::Model::Game' });
    unless ($game) {
        early_response_json({result => 'badGameId'})
    }
    $game
}

sub getGameInfo {
    my ($data) = @_;

    my ($game, $err);
    if (defined $data->{gameId}) {
        $game = _get_game_by_id($data->{gameId});
        $err = 'badGameId'
    } elsif (defined $data->{sid}) {
        init_user_by_sid($data->{sid});
        $game = global_game()
    }
    early_response_json({result => $err}) unless $game;

    my $res = $game->full_info();
    response_json({result => 'ok', gameInfo => $res})
}

sub getGameState {
    my ($data) = @_;
    my $game;
    if (defined $data->{gameId}) {
        $game = _get_game_by_id($data->{gameId})
    } elsif (defined $data->{sid}) {
        init_user_by_sid($data->{sid});
        $game = global_game()
    } else {
        assert(0, 'badJson')
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

sub loadGame {
    my ($data) = @_;
    proto($data, 'gameState');

    assert(!global_user()->activeGame(), 'alreadyInGame');
# TODO: it's bad if one user can load game. If you want to
# allow loading of active game you should add possibility
# to ask all users about game loading

    assert(ref($data->{gameState}) eq 'HASH', 'badGameSave',
           descr => 'notHash');

    my $game = _construct_new_game({
                   gameName => $data->{gameName},
                   gameDescr => $data->{gameDescr},
                   mapId => $data->{gameState}->{mapId} });

    $game->load_state($data->{gameState});
    db()->store_nonroot($game);

    response_json({result => 'ok'})
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
