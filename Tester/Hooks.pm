package Tester::Hooks;

use Exporter::Easy (
    EXPORT => [ qw(sid_to_params
                   sid_from_params
                   sid_from_to_params
                   set_sid
                   params_same_sid ) ]
);

sub sid_to_params {
    my $var = \$_[0];
    sub {
        use Data::Dumper;
        $_[1]->{_sid} = $_[0]->{sid} if defined $_[0]->{sid};
        $$var = $_[1]->{_sid};
    }
}

sub sid_from_params {
    my $var = \$_[0];
    sub {
        $_[0]->{sid} = $_[1]->{_sid} if defined $_[1]->{_sid};
        $$var = $_[1]->{_sid} if $var;
    }
}

sub sid_from_to_params {
    sub {
        #from params only if sid eq '' in test
        if (defined $_[1]->{_sid} &&
            defined $_[0]->{sid} && $_[0]->{sid} eq '')
        {
            $_[0]->{sid} = $_[1]->{_sid}
        }
        #to params always
        if (defined $_[0]->{sid}) {
            $_[1]->{_sid} = $_[0]->{sid}
        }
    }
}

sub set_sid {
    my ($sid) = @_;
    sub {
        $_[0]->{sid} = $sid
    }
}

sub params_same_sid {
    my $h = @_ ? $_[0] : {};
    $h->{in_hook} = sid_from_to_params();
    $h->{res_hook} = sid_from_to_params();
    $h->{out_hook} = sid_from_to_params();
    $h
}

1
