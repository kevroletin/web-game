package Game::Model::Region;
use Moose;

use Game::Environment qw(early_response_json);
use Moose::Util::TypeConstraints;

#class_type 'Game::Model::Region';

subtype 'Game::Model::Region::ExtraItems',
    as 'HashRef',
    where {
        my $a = [ 'dragon', 'fortifield', 'hero',
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
                    required => 0 );

has 'extraItems' => ( isa => 'Game::Model::Region::ExtraItems',
                      is => 'rw',
                      default => sub { {} } );

has 'inDecline' => ( isa => 'Bool',
                     is => 'rw',
                     default => 0 );

has 'landDescription' => ( isa => 'Game::Model::Region::landDescription',
                           is => 'rw',
                           # TODO:Fix default maps
                           # required => 1
                         );

has 'owner' => ( isa => 'Game::Model::User',
                 is => 'rw',
                 required => 0,
                 weak_ref => 1 );


has 'tokensNum' => ( isa => 'Int',
                     is => 'rw',
                     default => 0 );


1
