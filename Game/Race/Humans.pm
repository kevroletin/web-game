package Game::Race::Humans;
use Moose;

use Game::Environment qw(early_response_json global_user global_game);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'humans' }

sub tokens_cnt { 5 }

override 'compute_coins' => sub {
    my ($self, $reg) = @_;
    return super() if $self->inDecline();
    super() + grep { 'farmland' ~~ $_->landDescription() } @$reg;
};


1
