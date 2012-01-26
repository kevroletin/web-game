package Game::Power::Berserk;
use Moose::Role;

use Game::Environment qw(assert db response_json early_response_json global_user global_game);

with( 'Game::Roles::Power' );


has 'lastDiceValue' => ( isa => 'Maybe[Int]',
                         is => 'rw' );

sub power_name { 'berserk' }

sub _power_tokens_cnt { 4 }

sub throwDice {
    my ($self, $dice) = @_;
    assert(!defined $self->lastDiceValue(), 'badStage',
           descr => 'alreadyUsed', value => $self->lastDiceValue());
    assert(global_user()->tokensInHand() > 0, 'badStage', descr => 'noUnits');
    $dice ||= global_game()->random_dice();
    $self->lastDiceValue($dice);
    db()->update($self);

    response_json({result => 'ok', dice => $dice})
}

override '_calculate_land_strength' => sub {
    my ($self, $reg) = @_;
    $self->lastDiceValue() ? super() - $self->lastDiceValue() : super()
};

sub __clear_last_dice_value {
    my ($self) = @_;
    $self->lastDiceValue(undef);
    db()->update($self)
}

after 'conquer' => \&__clear_last_dice_value;

after 'turnFinished' => \&__clear_last_dice_value;


1
