package Tester::CheckState;
use warnings;
use strict;

use JSON;

use lib '..';
use Tester;
use Tester::OK;
use Tester::Hooks;
use Tester::State;
use Data::Dumper::Concise;
use Exporter::Easy ( EXPORT => [qw(GAME_STATE
                                   TOKENS_CNT
                                   REGION_EXTRA_ITEM
                                   check_user_state
                                   check_region_state)] );

# TODO: reduce copypaste
sub check_user_state {
    my ($checker, $params) = @_;
    unless (defined $params->{_number_in_game}) {
        return {res => 0,
                quick => 'bad test',
                long => 'bad test: player\'s order is missing'}
    }
    my $cmp = sub {
        my ($in, $out, $res) = @_;
        my $user = $res->{players}->[$params->{_number_in_game}];
        unless (defined $user) {
            return { res => 0,
                     quick => 'no user in response' }
        }
        $checker->($user)
    };
    my $in = '{"action": "getGameState", "sid": ""}';
    json_custom_compare_test($cmp, $in, '{}', $params)
}

sub check_region_state {
    my ($checker, $land_num, $params) = @_;
    my $cmp = sub {
        my ($in, $out, $res) = @_;
        my $reg = $res->{regions}->[$land_num];
        unless (defined $reg) {
            return { res => 0,
                     quick => 'no such region in response' }
        }
        $checker->($reg)
    };
    my $in = '{"action": "getGameState", "sid": ""}';
    json_custom_compare_test($cmp, $in, '{}', $params)
}


sub REGION_EXTRA_ITEM {
    my ($item, $cnt, $reg_num, $params) = @_;
    my $reg_cmp = sub {
        my ($reg) = @_;
        my $eic = $reg->{extraItems}->{$item};
        if ($cnt == 0 && !defined $eic ||
            defined $eic && $cnt == $eic) {
            return { res => 1, quick => 'ok' }
        }
        my $in_resp = defined $eic ?
            "$item in resp $eic != $cnt " :
            "there isn't $item";
        { res => 0, quick => $in_resp,
          long => "$in_resp\n" . Dumper($reg) }
    };
    OK( check_region_state($reg_cmp, $reg_num, $params),
        "check extra items: $item" )
}

sub GAME_STATE {
    my ($state, $params) = @_;
    my $cmp = sub {
        my ($in, $out, $res) = @_;
        unless (defined $res->{state}) {
            return { res => 0, quick => 'bad state',
                     long => 'state not defined'}
        }
        unless ($res->{state} eq $state) {
            return { res => 0, quick => 'ok',
                     long => "bad game state: $res->{state} != $state"}
        }
        { res => 1, quick => 'ok' }
    };
    my $in = '{"action": "getGameState", "sid": ""}';
    OK( json_custom_compare_test($cmp, $in, '{}', $params),
        "game state == $state" );
}

sub TOKENS_CNT {
    my ($cnt, $params) = @_;
    unless (defined $params->{_number_in_game}) {
        return {res => 0,
                quick => 'bad test',
                long => 'bad test: player\'s order is missing'}
    }
    my $cmp = sub {
        my ($in, $out, $res) = @_;
        my $res_cnt = $res->{players}->[$params->{_number_in_game}]->{tokensInHand};
        unless (defined $res_cnt) {
            return { res => 0,
                     quick => 'no tokens cnt in response' }
        }
        unless ($res_cnt eq $cnt) {
            return { res => 0, quick => 'tokens cnt deffers',
                     long => "tokens cnt in resp $res_cnt != $cnt"}
        }
        { res => 1, quick => 'ok' }
    };
    my $in = '{"action": "getGameState", "sid": ""}';
    OK( json_custom_compare_test($cmp, $in, '{}', $params),
        'check tokens in hand cnt' );
};



1
