use Game::Actions::Game;
use strict;
use warnings;

use Game::Actions;
use Game::Environment qw(:db :response);
use Game::Model::Game;
use Game::Model::AiUser;
use Storable q(dclone);
use Exporter::Easy ( OK => [qw(aiJoin
                               createGame
                               joinGame
                               leaveGame
                               getGameInfo
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

    my $map_clone = dclone($map);
    $map_clone->id(undef);

    $data->{ai} ||= 0;
    my $game = Game::Model::Game->new(
                   params_from_proto('gameName', 'gameDescr', 'ai'),
                   map => $map_clone
               );
    $game
}

sub createGame {
    my ($data) = @_;
    assert(!global_user()->activeGame(), 'alreadyInGame');

    unless (defined $data->{gameDescr}) {
        $data->{gameDescr} = $data->{gameDescription}
    }
    my $game = _construct_new_game($data);

    if (feature('join_game_after_creation')) {
        global_user()->activeGame($game);
    }
    $game->add_player(global_user());

    db()->store_nonroot($game);
    db()->update(global_user());

    response_json({ result => 'ok', gameId => $game->gameId() });
}

sub aiJoin {
    my ($data) = @_;
    proto($data, 'gameId');
    my $game = _get_game_by_id($data->{gameId});
    assert($game->state() eq 'notStarted', 'badGameState');
    assert($game->ai() - $game->aiJoined > 0, 'tooManyAi');

    my $name = sprintf("_ai%d.%d", $game->gameId(), $game->aiJoined());
    my $ai_user = Game::Model::User->new({username => $name,
                                          password => $name, isAi => 1});

    $ai_user->activeGame($game);
    $game->add_player($ai_user);
    $game->aiJoined( $game->aiJoined + 1 );

    $ai_user->generate_sid();
    db()->insert($ai_user);
    db()->update( $game );
    response_json({result => 'ok', sid => $ai_user->sid(),
                   id => int(@{$game->players()})});
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
    assert($game, $err);

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
    response_json({result => 'ok', gameState => $state})
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

    assert($game, 'badGameId');
    assert(!defined global_user()->activeGame(), 'alreadyInGame');
    assert($game->state() eq 'notStarted', 'badGameState');
    assert(@{$game->players()} < $game->map()->playersNum(), 'tooManyPlayers');
    if (feature('delete_empty_game')) {
        assert(@{$game->players()} != 0, 'badGameState')
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
    if (global_user()->username() =~ /^_ai/) {
        $game->aiJoined( $game->aiJoined - 1 )
    }

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
    assert(defined $data->{isReady}, 'badReadinessStatus');

    my $game = global_game();
    assert($game->state() eq 'notStarted', 'badGameState');

    global_user()->readinessStatus($data->{isReady});
    if ($game->ready()) {
        $game->state('conquer');
    }

    if (is_debug() && defined $data->{visibleRaces}) {
        $game->racesPack([map { ($_) } @{$data->{visibleRaces}}]);
        $game->powersPack([map { ($_) } @{$data->{visibleSpecialPowers}}]);
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
