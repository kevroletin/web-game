package Tester::CheckState;
use warnings;
use strict;

use JSON;

use lib '..';
use Tester;
use Tester::OK;
use Tester::Hooks;
use Tester::State;
use Exporter::Easy ( EXPORT => [qw(GAME_STATE
                                   TOKENS_CNT)] );

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
