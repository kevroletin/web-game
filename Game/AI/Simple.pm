package Game::AI::Simple;
use warnings;
use strict;

use base 'Game::AI::Base';

sub act_select_race {
    my ($s) = @_;
    ...
}

sub act_decline_or_conquer {
    my ($s) = @_;
    ...
}

sub act_conquer {
    my ($s) = @_;
    ...
}

sub act_defend {
    my ($s) = @_;
    ...
}

sub act_redeploy {
    my ($s) = @_;
    ...
}

sub act_redeployed {
    my ($s) = @_;
    ...
}

sub act_finish_turn {
    my ($s) = @_;
    ...
}

sub act_leave_game {
    my ($s) = @_;
    ...
}

1;
