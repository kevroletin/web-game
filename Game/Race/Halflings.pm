package Game::Race::Halflings;
use Moose;

use Game::Environment qw(:std :db :response);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


has 'holes_cnt' => ( isa => 'Int',
                     is => 'rw',
                     default => 0 );

sub race_name { 'halflings' }

sub tokens_cnt { 6 }

after 'holes_cnt' => sub {
    my ($self, $cnt) = @_;
    global_game()->raceStateStorage()->{holesPlaced} = $cnt
};

override '_check_land_reachability' => sub {
    return 1 unless global_user()->have_owned_active_regions();
    super()
};

after 'conquer' => sub {
    my ($self, $reg) = @_;
    return undef if $self->holes_cnt() >= 2 || $self->inDecline();
    $reg->extraItems()->{hole} = 1;
    $self->holes_cnt($self->holes_cnt() + 1);
    # TODO: investigate is it good idea to make db()->update
    # from multiple places
    db()->update($self)
};

before 'inDecline' => sub {
    my ($self, $value) = @_;
    if ($value && $value == 1) {
        for my $reg (global_user()->owned_regions()) {
            delete $reg->extraItems()->{hole}
        }
    }
};

before '_clear_left_region' => sub {
    my ($self, $reg) = @_;
    delete $reg->extraItems()->{hole}
};


1
