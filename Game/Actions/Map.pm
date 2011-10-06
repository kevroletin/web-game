package Game::Actions::Map;
use strict;
use warnings;

use Game::Actions;
use Game::Environment qw(db db_search_one
                         early_response_json
                         global_user
                         response_json);
use Game::Model::Map;


sub _gen_map_id {
    my ($cnt) = db_search({CLASS => '_mapIdCounter'})->all();
    if (!$cnt) {
        package _mapIdCounter;
        use Moose;

        has 'value' => (is => 'rw', isa => 'Int',
                        default => 0);
        no Moose;

        $cnt = _sidCounter->new();
    }
    $cnt->{value}++;
    db->store($cnt);
    return $cnt->{value};

}

sub uploadMap {
    my ($data) = @_;
    proto($data, 'mapName', 'playersNum', 'regions', 'turnsNum');

    my $map = db_search_one({ mapName => $data->{mapName} },
                            { CLASS => 'Game::Model::Map' });
    if ($map) {
        early_response_json({ result => 'mapTaken' })
    }

    $map = Game::Model::Map->new(params_from_proto(),
                                 id => _gen_map_id());
    db()->store($map);
    response_json({result => 'ok', mapId => $map->id()});
}


1;
