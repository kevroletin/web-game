use warnings;
use strict;

use Exporter::Easy ( EXPORT => [q(proto)] );
use Game::Environment q(early_response_json);


sub proto {
    my $data = shift;
    for (@_) {
        unless (defined $data->{$_}) {
            early_response_json({result => 'badJson'});
        }
    }
}

1;
