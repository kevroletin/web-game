package Game::Power::Fortified;
use Moose::Role;

use Game::Environment qw(early_response_json global_user global_game);
use List::Util qw( sum );

with( 'Game::Roles::Power' );


sub power_name { 'fortified' }

override 'compute_coins' => sub {
    my ($self, $regs, $stat) = @_;
    return super() if $self->inDecline();
    my $bonus = grep { defined $_->extraItems()->{fortified} } @$regs;
    $stat->{power} = $bonus unless $self->inDecline();
    super() + $bonus;
};

sub _power_tokens_cnt { 3 }

after '_redeploy_units' => sub {
    my ($self, $moves) = @_;
    my $reg = $moves->{fortified_reg};
    return unless $reg;

    if (defined $reg->extraItems()->{fortified}) {
        early_response_json(
            { result => 'tooManyFortifiedsInRegion' })
    }

    my $cnt = grep { defined $_->extraItems()->{fortified} }
                  global_user()->owned_regions();
    if ($cnt > 6) {
        early_response_json({result => 'tooManyFortifiedsOnMap'})
    }

    my $ei = $reg->extraItems();
    $ei->{fortified} = 1;
    $reg->extraItems($ei)
};

sub __remove_fortress {
    my ($self, $reg) = @_;
    delete $reg->extraItems()->{fortified}
};


after 'clear_reg_and_die' => \&__remove_fortress;

after '_clear_left_region' => \&__remove_fortress;


1
