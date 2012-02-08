package Game::Actions;
use warnings;
use strict;

use Exporter::Easy ( EXPORT => [qw(inc_counter
                                   get_game_by_id
                                   params_from_proto
                                   proto)] );
use Game::Environment qw(:std :response :db);
use Game::Model::Counter;

my $last_data = undef;
my $last_proto = undef;


sub params_from_proto {
    $last_proto = \@_ if @_;
    unless (defined $last_proto && defined $last_data) {
        die "Prototype undefined. May be you forgot" .
            "to call proto(\$data, 'field1', ... ) ?";
    }
    map { ($_ => $last_data->{$_}) } @{$last_proto}
}

sub proto {
    my $data = shift;
    for (@_) {
        assert(defined $data->{$_}, 'bad' . ucfirst($_));
#        assert(defined $data->{$_}, 'badJson');
    }
    $last_proto = \@_;
    $last_data = $data;
}

sub get_game_by_id {
    my ($id) = @_;
    my $game = db_search_one({ gameId => $id },
                             { CLASS => 'Game::Model::Game' });
    unless ($game) {
        early_response_json({result => 'badGameId'})
    }
    $game
}

1;
