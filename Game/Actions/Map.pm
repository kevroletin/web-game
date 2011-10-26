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
        my $n_map = db_search_one({ name => $map->{name} },
                                  { CLASS => 'Game::Model::Map'});
        db()->delete($n_map) if defined $n_map;
        $n_map = Game::Model::Map->new(%{$map});
        db()->insert_nonroot($n_map);
    }
    response_json({result => 'ok'});
}

sub uploadMap {
    my ($data) = @_;
    proto($data, 'mapName', 'playersNum', 'turnsNum', 'regions');

    my $map = db_search_one({ mapName => $data->{mapName} },
                            { CLASS => 'Game::Model::Map' });
    if ($map) {
        early_response_json({ result => 'mapNameTaken' })
    }

    my @regions;
    eval {
        @regions = map { Game::Model::Region->new($_) } @{$data->{regions}};
    };
    if ($@) {
        if (ref($@) eq 'Game::Exception::EarlyResponse' ) {
            die $@
        } else {
            early_response_json({result => 'badJson'})
        }
    }

    $map = Game::Model::Map->new(
               params_from_proto('mapName', 'playersNum', 'turnsNum'),
               regions => [@regions]
           );
    db()->insert_nonroot($map);
    response_json({result => 'ok', mapId => $map->id()});
}



1;