package Game::Model::Region;
use Moose;

use Game::Environment qw(early_response_json);
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


# TODO:
# FIXME: rename tokensNum -> population
sub tokensNum {
    my $self = shift;
    $self->population(@_);
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

sub owner_race {
    my ($self) = @_;
    return undef unless $self->owner();
    $self->inDecline() ? $self->owner()->declineRace() :
                         $self->owner()->activeRace()
}

1
