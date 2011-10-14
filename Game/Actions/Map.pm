package Game::Actions::Map;
use strict;
use warnings;

use Game::Actions;
use Game::Constants::Map;
use Game::Environment qw(db db_search_one
                         early_response_json
                         global_user
                         response_json);
use Game::Model::Map;
use Game::Model::Region;
use Exporter::Easy ( OK => [qw(createDefaultMaps uploadMap)] );


sub createDefaultMaps {
    for my $map (@Game::Constants::Map::maps) {
        my $n_map = db_search_one({ name => $_->{name} },
                                  { CLASS => 'Game::Model::Map'});
        db()->delete($n_map) if defined $n_map;
        $n_map = Game::Model::Map->new(%{$map});
        db()->store($n_map);
    }
    response_json({result => 'ok'});
}

sub uploadMap {
    my ($data) = @_;
    proto($data, 'mapName', 'playersNum', 'turnsNum');

    my $map = db_search_one({ mapName => $data->{mapName} },
                            { CLASS => 'Game::Model::Map' });
    if ($map) {
        early_response_json({ result => 'mapNameTaken' })
    }

    $map = Game::Model::Map->new(params_from_proto(),
                                 regions => $data->{regions});
    db()->store($map);
    response_json({result => 'ok', mapId => $map->id()});
}


1;
