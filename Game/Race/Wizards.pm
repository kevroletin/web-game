package Game::Race::Wizards;
use Moose;

use Game::Environment qw(early_response_json global_user global_game);

extends( 'Game::Race' );
with( 'Game::Roles::Race' );


sub race_name { 'wizards' }

sub tokens_cnt { 5 }

override 'compute_coins' => sub {
    my ($self, $reg, $st) = @_;
    return super() if $self->inDecline();
    super() + ($st->{race} = grep { 'magic' ~~ $_->landDescription() } @$reg);
};


1
