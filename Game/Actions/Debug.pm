package Game::Actions::Debug;
use strict;
use warnings;

use Game::Constants;
use Game::Actions;
use Game::Race::Debug;
use Game::Power::Debug;
use Game::Environment qw(:std :db :response);
use Moose::Util q(apply_all_roles);
use Exporter::Easy ( EXPORT => [qw(resetServer
                                   doSmth
                                   setBadge
                                   createBadgesPack
                                   selectGivenRace)] );


sub resetServer {
    my ($data) = @_;
    if (defined $data->{randSeed}) {
        srand($data->{randSeed})
    }
    if (1) {
        use DBI;
        my $dbh = eval{ DBI->connect('dbi:SQLite:dbname=tmp/test.db') };
        $dbh->do('delete from entries');
        $dbh->do('delete from gin_index;');
        die $DBI::errstr if $DBI::errstr;
    } else {
        unlink 'tmp/test.db';
        `rm -rf db`;
    }
    response_json({result => 'ok'});
}

sub doSmth {
    response_json({result => 'ok'})
}

sub setBadge {
    my ($data) = @_;
}

sub createBadgesPack {
    my ($data) = @_;
    proto($data, 'races', 'powers');

    my $game = global_game();
    my ($races, $powers) = ($data->{races}, $data->{powers});

    if (ref($races) ne 'ARRAY' || @$races == 0 ) {
        early_response_json({result => 'badRaces'})
    }
    for (@$races) {
        unless ($_ ~~ @Game::Constants::races) {
            early_response_json({result => ''})
        }
    }
    if (ref($powers) ne 'ARRAY' || @$powers == 0 ) {
        early_response_json({result => 'badPowers'})
    }
    for (@$powers) {
        unless ($_ ~~ @Game::Constants::powers) {
            early_response_json({result => 'badPowers'})
        }
    }

    $game->racesPack($races);
    $game->powersPack($powers);
    $game->bonusMoney([(0) x 6]);

    db()->update($game);
    response_json({result => 'ok'})
}

sub selectGivenRace {
    my ($data) = @_;
    proto($data, 'race', 'power');
    {
        use Game::Actions::Gameplay;
        $data->{action} = 'selectRace';
        Game::Actions::Gameplay::_control_state($data);
    }
    my $game = global_game();

    my $race = $data->{race};
    my $power = $data->{power};
    my $coins = $data->{coins};
    $coins = 0 unless $coins;
    unless ($race &&
            $race ~~ [@Game::Constants::races, 'debug']) {
        early_response_json({result => 'badRace'})
    }
    unless ($power &&
            $power ~~ [@Game::Constants::powers, 'debug']) {
        early_response_json({result => 'badPower'})
    }

    # FIXME: copypaste from &Game::Actions::Gameplay::selectRace

    global_user()->coins(global_user()->coins + $coins);

    my $pair = ("Game::Race::" . ucfirst($race))->new();
    apply_all_roles($pair, ("Game::Power::" . ucfirst($power)));
    global_user()->activeRace($pair);
    global_user()->tokensInHand($pair->tokens_cnt());

    $game->state('conquer');
    db()->store_nonroot($pair);
    db()->update($game, global_user());
    response_json({result => 'ok'});
}

1;
