package Game::Model::Region;
use Moose;

use Game::Environment qw(assert db_search_one
                         early_response_json);
use Moose::Util::TypeConstraints;
use Storable q(dclone);


subtype 'Game::Model::Region::ExtraItems',
    as 'HashRef',
    where {
        my $a = [ 'dragon', 'fortified', 'hero',
                  'encampment', 'hole' ];
        my $ok = 1;
        for my $k (keys %$_) { $ok &&= $k ~~ $a }
        $ok
    },
    message {
        #use Data::Dumper::Concise;
        #Dumper($_) . "is bad Game::Model::Region::ExtraItems."
        early_response_json({result => 'badRegions'})
    };

subtype 'Game::Model::Region::landDescription',
    as 'ArrayRef',
    where {
        my $a = [ 'border', 'coast', 'sea', 'mountain',
                  'mine', 'farmland', 'magic', 'forest',
                  'hill', 'swamp', 'cavern' ];
        my $ok = 1;
        for my $k (@$_) { $ok &&= $k ~~ $a }
        $ok
    },
    message {
        #"$_ is bad Game::Model::Region::landDescription"
        early_response_json({result => 'badRegions'})
    };


has 'adjacent' => ( isa => 'ArrayRef[Int]',
                    is => 'rw',
                    required => 1 );

has 'extraItems' => ( isa => 'Game::Model::Region::ExtraItems',
                      is => 'rw',
                      default => sub { {} } );

has 'inDecline' => ( isa => 'Bool',
                     is => 'rw',
                     default => 0 );

has 'landDescription' => ( isa => 'Game::Model::Region::landDescription',
                           is => 'rw',
                           required => 1
                         );

has 'owner' => ( isa => 'Maybe[Game::Model::User]',
                 is => 'rw',
                 required => 0,
                 weak_ref => 1 );


has 'population' => ( isa => 'Int',
                      is => 'rw',
                      required => 1 );

has 'coordinates' => ( isa => 'ArrayRef[ArrayRef[Int]]',
                       is => 'rw',
                       default => sub { [] } );

has 'bonusCoords' => ( isa => 'ArrayRef[Int]',
                       is => 'rw',
                       default => sub { [] } );

has 'raceCoords' => ( isa => 'ArrayRef[Int]',
                      is => 'rw',
                      default => sub { [] } );

has 'powerCoords' => ( isa => 'ArrayRef[Int]',
                       is => 'rw',
                       default => sub { [] } );


# TODO:
# FIXME: rename tokensNum -> population
sub tokensNum {
    shift->population(@_);
}

sub extract_state {
    my ($self) = @_;
    my $res = {};
    $res->{tokensNum} = $self->tokensNum();
    $res->{owner} = $self->owner() ? $self->owner()->id() : undef;
    $res->{inDecline} = $self->inDecline();
    $res->{extraItems} = dclone($self->extraItems());
    $res
}

sub extract_const_descr {
    my ($s) = @_;
    my $r = {};
    $r->{adjacent} = $s->{adjacent};
    $r->{coordinates} = $s->{coordinates};
    $r->{landDescription} = $s->{landDescription};
    $r->{bonusCoords} = $s->{bonusCoords};
    $r->{raceCoords} = $s->{raceCoords};
    $r->{powerCoords} = $s->{powerCoords};
    $r
}

# should be already checked: $data->{regions}->[$i]->{owner}
sub load_state {
    my ($self, $data) = @_;
    my $err = 'badRegions';

    assert(defined $data->{tokensNum} &&
           $data->{tokensNum} =~ /^\d+$/, $err,
            badTokensNum => $data->{tokensNum});
    $self->tokensNum($data->{tokensNum});

    if (defined $data->{owner}) {
        my $u = db_search_one({ CLASS => 'Game::Model::User' },
                              { id => $data->{owner} });
        $self->owner($u);
        assert($self->owner, $err, 'badOwner' => $data->{owner});
    }

    assert($data->{inDecline} ~~ [0, 1], $err,
           badInDecline => $data->{inDecline});
    $self->inDecline($data->{inDecline});

    my $ok = find_type_constraint(
                 'Game::Model::Region::ExtraItems'
             )->check($data->{extraItems});
    assert($ok, $err, 'badExtraItems' => $data->{extraItems});
    $self->extraItems($data->{extraItems});
}

sub owner_race {
    my ($self) = @_;
    return undef unless $self->owner();
    $self->inDecline() ? $self->owner()->declineRace() :
                         $self->owner()->activeRace()
}

1
