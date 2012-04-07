package Tester::Dumper;
use warnings;
use strict;
use v5.10;

use Data::Dumper ();
use JSON;
use Exporter::Easy ( EXPORT => ['Dumper'] );


sub remove_bool {
    given (ref($_[0])) {
        when ('ARRAY') {
            for my $i (0 .. $#{$_[0]}) {
                remove_bool($_[0]->[$i])
            }
        }
        when ('HASH') {
            for my $k (keys %{$_[0]}) {
                remove_bool($_[0]->{$k})
            }
        }
        when ('') {
        }
        when (/JSON.*Boolean/) {
            $_[0] = ($_[0] ? 'JSON::true' : 'JSON::false')
        }
    }
}

# Workaround to dump JSON::Boolean values as true or false
sub Dumper {
    for my $i (0 .. $#_) {
        remove_bool($_[$i]);
    }

    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Useqq = 1;
    local $Data::Dumper::Deparse = 1;
    local $Data::Dumper::Quotekeys = 0;
    local $Data::Dumper::Sortkeys = 1;

    $_ = Data::Dumper->Dump([@_]);
    while (s/"JSON::true"/true/g) {}
    while (s/"JSON::false"/false/g) {}
    $_
}


1;
