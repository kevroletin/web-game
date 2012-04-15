package Game::AI::Random;
use warnings;
use strict;

use base 'Game::AI::Base';

use List::Util 'shuffle';

sub before_turn_hook {
    my ($s) = @_;
    $s->{storage}{regions_to_conquer} =
        [shuffle 1 .. @{$s->last_map_regions()}]
}

sub after_turn_hook {
    my ($s) = @_;
    delete $s->{storage}{regions_to_conquer}
}

sub act_select_race {
    my ($s) = @_;
    my $pos = int rand(6);
    $s->cmd_select_race($pos)
}

sub act_decline_or_conquer {
    my ($s) = @_;
    if (rand() < 0.2) {
        $s->send_cmd(action => 'decline');
    } else {
        $s->act_conquer();
    }
}

sub act_conquer {
    my ($s) = @_;
    my $reg_id = pop @{$s->{storage}{regions_to_conquer}};

    unless (defined $reg_id) {
        $s->info('attempts to do conquer finished; do redeploy');
        return $s->execute_action('redeploy');
    }

    $s->debug(sprintf "conquer region %s", $reg_id);
    $s->cmd_conquer($reg_id)
}

sub act_defend {
    my ($s) = @_;
    $s->send_cmd(action => 'defend',
                 regions => []);
}

sub act_redeploy {
    my ($s) = @_;
    my @regs;
    my $i = 1;
    for (@{$s->last_map_regions()}) {
        if (!$_->{inDecline} && ($_->{owner} // '') eq $s->{data}{id}) {
            push @regs, [$i, $_]
        }
        ++$i;
    }
    my $res = {
      action => "redeploy",
      regions => []
    };
    for (@regs) {
        push @{$res->{regions}}, { regionId => $_->[0],
                                   tokensNum => $_->[1]->{tokensNum} }
    }

    my $to_redeploy = $s->active_player()->{tokensInHand};
    $to_redeploy -= 4 if $s->active_player()->{activeRace} eq 'amazons';
    $i = 0;
    for (1 .. $to_redeploy) {
        ++$res->{regions}[$i]{tokensNum};
        $i = ($i + 1) % @{$res->{regions}};
    }

    $s->send_cmd($res);
}

sub act_finish_turn {
    my ($s) = @_;
    $s->send_cmd(action => 'finishTurn');
}

1;
