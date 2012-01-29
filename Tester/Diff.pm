package Tester::Diff;
use warnings;
use strict;
use v5.10;

use Exporter::Easy ( OK => ['compare'] );

use Carp;
$SIG{__DIE__} = sub { Carp::confess @_ };
$SIG{__WARN__} = sub { Carp::confess @_ };

sub pretty_ref {
    return 'undef' if !defined $_[0];
    return 'scalar' if ref($_[0]) eq '';
    return ref $_[0];
}

sub _cmp_array {
    my ($a, $b, $method, $path) = @_;

    my @res;
    my $res = { ok => 1, path => "$path" };
    given (ref $b) {
        when ('CODE') {
            $res->{msg} = 'exec sub';
            $res->{ok} = $b->($a, $res, $method);
        }
        when ('ARRAY') {
            $res->{msg} = 'ARRAY vs ARRAY';
            for my $i (0 .. $#{$a}) {
                push @res,
                    _deep_compare($a->[$i], $b->[$i], $method, "${path}[$i]")
            }
            if (@$b > @$a) {
                my $msg = sprintf("array length %d != %d", int @$a, int @$b);
                unshift @res, { ok => 0, path => $path, msg => $msg }
            }
            return @res;
        }
        default {
            $res->{ok} = 0;
            $res->{msg} = 'ARRAY vs ' . pretty_ref($b)
        }
    }
    $res, @res
}

sub _cmp_hash {
    my ($a, $b, $method, $path) = @_;

    my @res;
    my $res = { ok => 1, path => "$path" };
    given (ref $b) {
        when ('CODE') {
            $res->{msg} = 'exec sub';
            $res->{ok} = $b->($a, $res, $method);
        }
        when ('HASH') {
            $res->{msg} = 'HASH vs HASH';
            for my $k (sort keys %$b) {
                push @res,
                    _deep_compare($a->{$k}, $b->{$k}, $method, "${path}{$k}")
            }
            if ($method eq 'EXACT') {
                for my $k (sort keys %$a) {
                    push @res,
                        _deep_compare($a->{$k}, $b->{$k}, $method, "${path}{$k}")
#                    unless (exists $a->{$k}) {
#                        unshift @res, { ok => 0, path => $path,
#                                        msg => "missing hash keys $k" }
#                    }
                }
            }
        }
        default {
            $res->{ok} = 0;
            $res->{msg} = 'HASH vs ' . pretty_ref($b)
        }
    }
    $res, @res
}

sub _cmp_scalar {
    my ($a, $b, $method, $path) = @_;

    my $res = { ok => 1, path => "$path", msg => 'SCALAR vs SCALAR' };
    given (ref $b) {
        when ('CODE') {
            $res->{msg} = 'exec sub';
            $res->{ok} = $b->($a, $res, $method);
        }
        when ($_ eq '' || ref($a) eq ref($b)) {
            break if !defined $a && !defined $b;
            if (defined $b) {
                unless (defined $a) {
                    $res->{ok} = 0;
                    $res->{msg} = 'undef vs ' . $b;
                } elsif($a ne $b) {
                    $res->{ok} = 0;
                    $res->{msg} = $a . ' vs ' . $b;
                }
            } else {
                if (defined $a) {
                    $res->{ok} = 0;
                    $res->{msg} = "$a vs undef";
                }
            }
        }
        default {
            $res->{ok} = 0;
            $res->{msg} = 'SCALAR vs ' . pretty_ref($b)
        }
    }
    $res
}

sub _deep_compare {
    my ($a, $b, $method, $path) = @_;

    given (ref $a) {
        when ('ARRAY') {
            return _cmp_array($a, $b, $method, $path)
        }
        when ('HASH') {
            return _cmp_hash($a, $b, $method, $path)
        }
        when ('CODE') {
            return { ok => 0, path => $path, msg => 'CODE as 1st arg' }
        }
        default {
            if (ref($b) eq 'CODE') {
                my $res->{msg} = 'exec sub';
                $res->{path} = $path;
                $res->{ok} = $b->($a, $res, $method);
                return $res;
            }
            return _cmp_scalar($a, $b, $method, $path) if (ref($b) eq ref($a));
            return { ok => 0, path => $path,
                     msg => pretty_ref($a) . ' vs ' . pretty_ref($b) }
        }
    }
}

sub compare {
    my ($a, $b, $method) = @_;
    $method ||= 'AT_LEAST';

    my $res = [_deep_compare($a, $b, $method, '')];
    bless($res, 'Tester::Diff::Report');
    $res
}

1;

package Tester::Diff::Report;
use warnings;
use strict;

sub errors_report {
    my ($self, $indent) = @_;
    $indent = 4 unless defined $indent;

    $indent = join '', ((' ') x $indent);
    join "\n",
        map { $indent . $_->{path} . ': ' . $_->{msg} }
            grep { !$_->{ok} } @$self
}

1;
