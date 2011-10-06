use warnings;
use strict;

use Exporter::Easy ( EXPORT => [qw(params_from_proto proto)] );
use Game::Environment q(early_response_json);

my $last_data = undef;
my $last_proto = undef;

sub params_from_proto {
    unless (defined $last_proto && defined $last_data) {
        die "Prototype undefined(may be you forgot" .
            "to call proto(\$data, 'field1', ...";
    }
    map { ($_ => $last_data->{$_}) } @{$last_proto}
}

sub proto {
    my $data = shift;
    for (@_) {
        unless (defined $data->{$_}) {
            early_response_json({result => 'badJson'});
        }
    }
    $last_proto = \@_;
    $last_data = $data;
}

1;
