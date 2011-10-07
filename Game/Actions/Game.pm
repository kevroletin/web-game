use Game::Actions::Game;
use strict;
use warnings;

use Game::Actions;
use Game::Environment qw(db db_search db_search_one
                         early_response_json
                         global_user
                         response response_json);
use Game::Model::Game;
use Scalar::Util q(looks_like_number);
use Exporter::Easy ( OK => [q(createGame)] );


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


1
