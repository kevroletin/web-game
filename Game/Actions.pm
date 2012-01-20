package Game::Actions;
use warnings;
use strict;

use Exporter::Easy ( EXPORT => [qw(inc_counter
                                   params_from_proto
                                   proto)] );
use Game::Environment qw(assert db db_search_one early_response_json);
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


1;
