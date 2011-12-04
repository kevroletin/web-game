package Game::Actions::Map;
use strict;
use warnings;

use Game::Actions;
use Game::Constants::Map;
use Game::Environment qw(db
                         db_search
                         db_search_one
                         early_response_json
                         init_user_by_sid
                         global_user
                         global_game
                         response_json);
use Game::Model::Map;
use Game::Model::Region;
use Exporter::Easy ( OK => [qw(createDefaultMaps
                               getMapList
                               getMapInfo
                               uploadMap)] );


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

sub getMapList {
    my @q = db_search({ CLASS => 'Game::Model::Map' })->all();
    my @maps = map { $_->short_info() } @q;
    response_json({result => 'ok', maps => \@maps});
}

sub getMapInfo {
    my ($data) = @_;
    my ($map, $err);
    if (defined $data->{mapId}) {
        $map = db_search_one({ id => $data->{mapId} },
                             { CLASS => 'Game::Model::Map' });
        $err = 'badMapId'
    } elsif (defined $data->{mapName}) {
        $map = db_search_one({ mapName => $data->{mapName} },
                             { CLASS => 'Game::Model::Map' });
        $err = 'badMapName'
    } elsif (defined $data->{sid}) {
        init_user_by_sid($data->{sid});
        $map = global_game()->map();
        $err = 'notInGame'
    } else {
        $err = 'badJson'
    }
    unless ($map) {
        early_response_json({result => $err})
    }
    response_json({ result => 'ok',
                    mapInfo => $map->full_info() });
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
