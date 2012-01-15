package Game::Power::Berserk;
use Moose::Role;

use Game::Environment qw(db response_json early_response_json global_user global_game);

with( 'Game::Roles::Power' );


has 'lastDiceValue' => ( isa => 'Maybe[Int]',
                         is => 'rw' );

sub power_name { 'berserk' }

sub _power_tokens_cnt { 4 }

sub throwDice {
    my ($self) = @_;
    if (defined $self->lastDiceValue() ||
        global_user()->tokensInHand() == 0)
    {
        early_response_json({result => 'badStage'})
    }
    my $dice = int rand(4);
    $self->lastDiceValue($dice);
    db()->update($self);

    response_json({result => 'ok', dice => $dice})
}

override '_calculate_land_strength' => sub {
    my ($self, $reg) = @_;
    $self->lastDiceValue() ? super() - $self->lastDiceValue() : super()
};

after 'conquer' => sub {
    my ($self) = @_;
    $self->lastDiceValue(undef);
    db()->update($self)
};

1
