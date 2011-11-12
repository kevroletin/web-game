package Game::Power::Stout;
use Moose::Role;

use Game::Environment qw(db early_response_json global_user
                         global_game);

with( 'Game::Roles::Power' );


has 'declineRequested' => ( isa => 'Bool',
                            is => 'rw',
                            default => 0 );

sub power_name { 'stout' }

sub _power_tokens_cnt { 4 }

override 'decline' => sub {
    my ($self) = @_;
    if (global_game()->state() ne 'redeployed') {
        return super()
    }
    $self->declineRequested(1);
    db()->update($self);
    response_json({result => 'ok'})
};

sub turnFinished {
    my ($self) = @_;
    if ($self->declineRequested()) {
        $self->decline();
        $self->declineRequested(0);
        db()->update($self)
    }
}




1
