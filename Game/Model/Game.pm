package Game::Model::Game;
use Moose;
use v5.10;

use Game::Constants qw(races_with_debug powers_with_debug);
use Game::Environment qw(:std :db);
use Game::Model::Map;
use Game::Model::User;
use KiokuDB::Set;
use Moose::Util::TypeConstraints;
use KiokuDB::Util q(weak_set);
use List::Util q(shuffle);
use Data::Dumper;

our @db_index = qw(gameName gameId);


subtype 'Game::Model::Game::GameName',
    as 'Str',
    where { 0 < length($_) && length($_) <= 50 },
    message { assert(0, 'badGameName'), };

#subtype 'Game::Model::Game::GameName::PlayersNum',
#    as 'Int',
#    where { 0 < $_ && $_ <= 5 },
#    message { assert(0, 'badnumberOfPlayers') }

subtype 'Game::Model::Game::GameDescr',
    as 'Maybe[Str]',
    where { !defined $_ || length($_) <= 300 },
    message { assert(0, 'badGameDescription') };

subtype 'Game::Model::Game::Ai',
    as 'Int',
    where {  !defined $_ || $_ <= 4 },
    message { assert(0, 'badAi' ) };


has 'gameName' => ( isa => 'Game::Model::Game::GameName',
                    is => 'ro',
                    required => 1 );

has 'map' => ( isa => 'Game::Model::Map',
               is => 'rw',
               required => 0 );

has 'gameDescr' => ( isa => 'Game::Model::Game::GameDescr',
                     is => 'rw' );

has 'players' => ( isa => 'ArrayRef[Game::Model::User]',
                   is => 'rw',
                   default => sub { [] } );

has 'activePlayerNum' => ( isa => 'Int',
                           is => 'rw',
                           default => 0 );

has 'gameId' => ( isa => 'Int',
                  is => 'ro',
                  required => 0 );

has 'state' => ( isa => 'Str',
                 is => 'rw',
                 default => 'notStarted' );

# TODO: consolidate into one structure next 4 fields
has 'racesPack' => ( isa => 'ArrayRef[Str]',
                     is => 'rw',
                     default => sub { [] } );

has 'powersPack' => ( isa => 'ArrayRef[Str]',
                      is => 'rw',
                      default => sub { [] } );

has 'bonusMoney' => ( isa => 'ArrayRef[Int]',
                      is => 'rw',
                      default => sub { [(0) x 6] } );

has 'tokenBadgeIds' => ( isa => 'ArrayRef[Int]',
                         is => 'rw',
                         default => sub { [1 .. 6] } );

has 'lasTokenBadgeId' => ( isa => 'Int',
                           is => 'rw',
                           default => 6 );

has 'history' => ( isa => 'ArrayRef',
                   is => 'rw',
                   default => sub { [] } );

has 'raceStateStorage' => ( isa => 'HashRef',
                            is => 'rw',
                            default => sub { {} } );

has 'ai' => ( isa => 'Game::Model::Game::Ai',
              is => 'rw',
              default => 0 );

has 'aiJoined' => ( isa => 'Int',
                    is => 'rw',
                    default => 0 );

has 'turn' => ( isa => 'Int',
                is => 'rw',
                default => 0 );

has 'lastDiceValue' => ( isa => 'Maybe[Int]',
                         is => 'rw',
                         required => 0 );

has 'last_action' => ( isa => 'Str',
                       is => 'rw' );

has 'raceSelected' => ( isa => 'Bool',
                        is => 'rw',
                        default => 0 );

has 'features' => ( isa => 'HashRef',
                    is => 'rw',
                    default => sub { {} } );


sub BUILD {
    my ($self) = @_;
    assert($self->ai() <= $self->map()->playersNum, 'badAiNum');
}

sub init_id {
    my ($self) = @_;
    $self->{gameId} = inc_counter('Game::Model::Game::gameId');
}

before 'state' => sub {
    my ($self, $new_state) = @_;
    if (defined $new_state &&
        $self->state() eq 'notStarted' &&
        $new_state ne 'notStarted' &&
        !@{$self->racesPack()})
    {
        $self->_create_tokens_pack()
    }
};

sub activePlayer {
    my ($self) = @_;
    $self->players()->[$self->activePlayerNum()]
}

sub add_player {
    my ($self, $user) = @_;
    push @{$self->players()}, $user
}

sub add_to_attack_history {
    my ($self, $reg) = @_;
    my $h = { whom => $reg->owner(),
              tokensNum => $reg->tokensNum(),
              region => $reg };
    push @{$self->history()}, $h;
}

sub _create_tokens_pack {
    my ($self) = @_;
    $self->racesPack([shuffle @Game::Constants::races]);
    $self->powersPack([shuffle @Game::Constants::powers]);
}

sub remove_player {
    my ($self, $user) = @_;
    assert($self->state() ~~ ['notStarted', 'finished'], 'badStage');
    my $nu = [ grep { $_ ne $user } @{$self->players()} ];
    $self->players($nu);
}

sub lastAttack {
    my $self = shift;
    return undef unless @{$self->history()};
    $self->{history}->[-1]
}

sub next_player {
    my ($self) = @_;
    my $n = $self->activePlayerNum() + 1;
    if ($n >= @{$self->players()}) {
        $n = 0;
        $self->turn($self->turn() + 1);
    }
    $self->history([]);
    $self->activePlayerNum($n);
    $self->lastDiceValue(undef);
    $self->raceSelected(0);
}

sub number_of_user {
    my ($self, $user) = @_;
    return undef unless $user;
    my $i = 0;
    for (@{$self->players()}) {
        return $i if $_ eq $user;
        ++$i
    }
    undef
}

sub get_player_by_id {
    my ($self, $user_id) = @_;
    for (@{$self->players()}) {
        return $_ if $_->id() eq $user_id
    }
    undef
}

sub ready {
    my ($self) = @_;
    return 0 unless @{$self->players()} > 1;
    return 0 if $self->ai() != $self->aiJoined();
    for my $user (@{$self->players()}) {
        return 0 unless $user->readinessStatus()
    }
    1
}

sub pick_tokens {
    my ($self, $race_num) = @_;
    my $race = splice @{$self->racesPack()}, $race_num, 1;
    my $power = splice @{$self->powersPack()}, $race_num, 1;
    my $coins = splice @{$self->bonusMoney()}, $race_num, 1;
    my $id =  splice @{$self->tokenBadgeIds()}, $race_num, 1;
    push @{$self->bonusMoney()}, 0;
    push @{$self->tokenBadgeIds()}, ++$self->{lasTokenBadgeId};
    ($race, $power, $id, $coins)
}

sub put_back_tokens {
    my ($self, $race) = @_;
    push @{$self->racesPack()}, $race->race_name();
    push @{$self->powersPack()}, $race->power_name();
}

sub random_dice { int rand(4) }

# --- extract state ---

sub _extract_last_attack {
    my ($self) = @_;
    my $la = $self->lastAttack();
    return undef unless $la;
    { whom => $la->{whom} ? $la->{whom}->id() : undef,
      tokensNum => $la->{tokensNum},
      reg => $self->($la->{region}->regionId()) }
}

sub _extract_visible_tokens {
    my ($self) = @_;
    my @res;
    for my $i (0 .. 5) {
        my $tok = {};
        my $uc_f = sub { defined $_[0] ? ucfirst($_[0]) : undef };
        if (feature('durty_gameState')) {
            $tok->{tokenBadgeId} = $self->tokenBadgeIds()->[$i];
            $tok->{position} = $i
        }
        $tok->{raceName} = $uc_f->($self->racesPack()->[$i]);
        $tok->{specialPowerName} = $uc_f->($self->powersPack()->[$i]);
        $tok->{bonusMoney} = $self->bonusMoney()->[$i];
        push @res, $tok
    }
    \@res
}

sub _copy_races_state_storage {
    my ($self, $st) = @_;

    $st->{dragonAttacked} = bool(0);
    $st->{enchanted} = bool(0);
    $st->{gotWealthy} = bool(0);
    $st->{friendInfo} = undef;
    #$st->{stoutStatistcs} = undef;
    $st->{declineRequested} = bool(0);
    $st->{berserkDice} = undef;
    $st->{holesPlaced} = 0;

    for (keys %{$self->raceStateStorage()}) {
        $st->{$_} = $self->raceStateStorage()->{$_}
    }
}

sub _extract_history {
    my ($self) = @_;
    my $h = sub {
        my $r = $_[0];
        $r->{whom} = $r->{whom}->id() if ($r->{whom} );
        $r->{region} = $r->{region}->regionId();
        $r
    };
    my @res = map { $h->($_) } @{$self->history()};
    \@res
}

sub _extract_players_state {
    feature('durty_gameState') ?
        shift->_extract_players_state_durty(@_) :
        shift->_extract_players_state_clear(@_)
}

sub _extract_players_state_durty {
    my ($s) = @_;
    my $res = [];
    for my $i (0 .. $#{$s->players()}) {
        my $st = {};
        my $p = $s->players()->[$i];
        $st->{userId} = $p->id();
        $st->{username} = $p->username();
        $st->{coins} = $p->coins();
        $st->{priority} = $i + 1;
        $st->{isReady} = bool( $p->readinessStatus );
        $st->{tokensInHand} = $p->tokensInHand();
        $st->{inGame} = bool(1);
        my $extract_race = sub {
            my ($race) = @_;
            return undef unless $race;
            {
                raceName => ucfirst($race->race_name()),
                specialPowerName => ucfirst($race->power_name()),
                tokenBadgeId => $race->tokenBadgeId(),
                totalTokensNum => $race->total_tokens_num()
            }
        };
        $st->{currentTokenBadge} = $extract_race->($p->activeRace());
        $st->{declinedTokenBadge} = $extract_race->($p->declineRace());
        push @{$res}, $st
    }
    $res
}

sub _extract_players_state_clear {
    my ($s) = @_;
    [ map { $_->extract_state() } @{$s->players()} ]
}

sub extract_state {
    feature('durty_gameState') ?
        shift->extract_state_durty(@_) :
        shift->extract_state_clear(@_)
}

sub extract_state_durty {
    my ($s) = @_;
    my $res = {};

    $res->{activePlayerId} = $s->activePlayer() ?
                                 $s->activePlayer()->id() : undef;
    $res->{currentPlayersNum} = @{$s->players()};
    $res->{currentTurn} = $s->turn();
    $res->{gameDescription} = $s->gameDescr();
    $res->{gameDescr} = $s->gameDescr();
    $res->{gameId} = $s->gameId();
    $res->{gameName} = $s->gameName();
    $res->{players} = $s->_extract_players_state_durty();
    $res->{visibleTokenBadges} = $s->_extract_visible_tokens();
    $res->{map} = $s->map()->extract_state_durty();

    $res->{aiRequiredNum} = $s->ai() - $s->aiJoined();
    $res->{state} = $s->magic_game_state_field();

    if ($s->state() eq 'defend') {
        $res->{defendingInfo} = {
            playerId => $s->lastAttack()->{whom}->userId(),
            regionId => $s->lastAttack()->{region}->regionId()
        }
    }

    $res->{stage} = $s->stage();
    $res->{lastEvent} = num($s->magic_last_event());

    $s->_copy_races_state_storage($res);
    $res
}

sub extract_state_clear {
    my ($s) = @_;
    my $res = {};

    $res->{activePlayerNum} = $s->activePlayerNum();
    $res->{attacksHistory} = $s->_extract_history();
# Shouldn't be used in theory
#    $res->{lastAttack} = $s->_extract_last_attack();
    $res->{mapId} = $s->map()->prev_id();
    $res->{raceSelected} = bool($s->raceSelected());
    $res->{state} = $s->state();
    $res->{turn} = $s->turn();
    $res->{lastDiceValue} = $_ if defined ($_ = $s->lastDiceValue());

    $res->{players} = $s->_extract_players_state_clear();
    $res->{regions} = $s->map()->extract_state_clear();
    if ($s->state() ne 'finished') {
        $res->{visibleTokenBadges} = $s->_extract_visible_tokens();
    }

    $res->{features} = $s->features() if $s->features();

    $s->_copy_races_state_storage($res);
    $res
}

sub game_state_field {
    my ($s) = @_;
    if ($s->state() eq 'notStarted') {
        'wait'
    } elsif ($s->state() eq 'finished') {
        if (@{$s->players()}) {
            'finish'
        } else {
            'empty'
        }
    } else {
        if (defined $s->last_action()) {
            'in_game'
        } else {
            'begin'
        }
    }
}

sub magic_game_state_field {
    {
        wait    => 1,
        begin   => 0,
        in_game => 2,
        finish  => 3,
        empty   => 4
    }->{shift->game_state_field()}
}

sub last_event {
    my ($self) = @_;
    my $state = $self->game_state_field();

    return $state unless $state eq 'in_game';
    given ($self->last_action) {
        when ($_ eq 'conquer' && defined $self->lastDiceValue()) {
            return 'failed_conquer'
        }
        return $_;
    }
}

sub magic_last_event {
    my ($self) = @_;
    my %h = (
        wait       =>  1,
#        begin   => not used
        in_game    =>  2,
        finish     =>  4,  # as finishTurn
        empty      =>  4,  # as finishTurn
        finishTurn =>  4,
        selectRace =>  5,
        conquer    =>  6,
        dragonAttack => 6, # as conquer
        enchant    =>  6,  # as conquer
        decline    =>  7,
        redeploy   =>  8,
        throwDice =>  9,
        defend     => 12,
        selectFriend  => 13,

        failed_conquer => 14
    );
    $h{$self->last_event()};
}

sub stage {
    my ($self) = @_;
    my $st = $self->state();
    given ($st) {
        when ('conquer') {
            if (global_game()->raceSelected()) {
#                return 'beforeConquest';
                return 'conquest'
            } elsif (defined $self->activePlayer()->activeRace()) {
                return 'beforeConquest' unless @{$self->history()};
                return 'conquest'
            } else {
                return 'selectRace'
            }
        }
        when ('notStarted') {
            return 'selectRace'
        }
        when ('redeployed') {
            return 'beforeFinishTurn'
        }
        when ('declined') {
            return 'finishTurn'
        }
        when ('finished') {
            return 'gameOver'
        }
        default {
            return $st
        }
    }
}

sub short_info {
    feature('durty_gameState') ?
        shift->short_info_durty(@_) :
        shift->short_info_clear(@_)
}

sub short_info_durty {
    my ($s) = @_;
    my $res = {
        gameId => $s->gameId(),
        gameName => $s->gameName(),
        gameDescr => $s->gameDescr(),
        playersNum => scalar @{$s->players()},
        maxPlayersNum => $s->map()->playersNum(),
        activePlayerId => ($_ = $s->activePlayer()) ? $_->id() : undef,
        turn => $s->turn(),
        turnsNum => $s->map()->turnsNum(),
        mapId => $s->map()->prev_id(),
        mapName => $s->map()->mapName(),
        aiRequiredNum => $s->ai() - $s->aiJoined(),
        state => $s->magic_game_state_field()
    };
    my $extract_user = sub {
        my ($user) = @_;
        {
            isReady => bool( $user->readinessStatus() ),
            userId => $user->{id},
            username => $user->{username},
            inGame => bool($user->activeGame())
        }
    };
    $res->{players} = [map { $extract_user->($_) } @{$s->players()}];
    $res
}

sub short_info_clear {
    my ($s) = @_;
    {
        activePlayerId => ( $_ = $s->activePlayer() ) ? $_->id() : $_,
        aiRequiredNum => $s->ai() - $s->aiJoined(),
        gameId => $s->gameId(),
        gameName => $s->gameName(),
        gameDescr => $s->gameDescr(),
        mapId => $s->map()->prev_id(),
        mapName => $s->map()->mapName(),
        maxPlayersNum => $s->map()->playersNum(),
        playersNum => scalar @{$s->players()},
        turn => $s->turn(),
        turnsNum => $s->map()->turnsNum(),
        state => $s->state()
    }
}

sub full_info {
    my ($s) = @_;
    my $state = $s->extract_state_clear();
    my $s_i = $s->short_info();
    for my $k (keys %{$s_i}) {
        $state->{$k} = $s_i->{$k}
    }
    $state->{aiRequiredNum} = $s->ai() - $s->aiJoined();
    for my $i (0 .. $#{$s->players()}) {
        $state->{players}->[$i]->{name} =
            $s->players()->[$i]->{username}
    }
    $state
}

# --- load state ---

sub _load_players_from_state {
    my ($self, $data) = @_;
    assert(ref($data->{players}) eq 'ARRAY', 'badPlayers');
    my $load_user = sub {
        my ($id) = @_;
        # FIXME: provide more explicit sollution
        # if !defined $self->id() => we construct game object from AI
        # not for storing in db
        my $p;
        if (defined $self->gameId()) {
            $p = db_search_one({ CLASS => 'Game::Model::User' },
                               { id => $id })
        } else {
            $p = Game::Model::User->new(username => 'loaded-user',
                                        password => 'dummy-password',
                                        id => $id);
        }
        assert($p, 'badUserId', userId => $id);
        assert(!$p->activeGame(), 'alreadyInGame', userId => $id);
        $p->activeGame($self);
        $p->load_state($_);
        $p
    };
    my @res = map { $load_user->($_->{id}) } @{$data->{players}};
    $self->players(\@res);
}

sub _load_token_badges_from_state {
    my ($self, $data) = @_;
    assert(ref($data->{visibleTokenBadges}) eq 'ARRAY',
           'badVisibleTokenBadges', descr => 'notArrayRef');
    my (@race_p, @pow_p, @mon);

    for (@{$data->{visibleTokenBadges}}) {
        assert(ref($_) eq 'HASH', 'badVisibleTokenBadges',
               notHash => $_);
        my ($race, $power) = (lcfirst($_->{raceName}),
                              lcfirst($_->{specialPowerName}));

        assert(defined $race &&
               ($race ~~ races_with_debug()),
               'badRace', race => $race);
        assert(defined $power &&
               ($power ~~ powers_with_debug()),
               'badPower', power => $power);
        assert(defined $_->{bonusMoney} &&
               $_->{bonusMoney} =~ /^\d+$/, 'badBonusMoney');
        push @race_p, $race;
        push @pow_p, $power;
        push @mon, $_->{bonusMoney};
    }
    $self->racesPack(\@race_p);
    $self->powersPack(\@pow_p);
    $self->bonusMoney(\@mon);
}

# should be loaded: $self->players
sub _load_regions_from_state {
    my ($self, $data) = @_;
    assert(ref($data->{regions}) eq 'ARRAY', 'badRegions',
           descr => 'notHash');
    assert(@{$data->{regions}} == @{$self->map()->regions()},
           'badRegionsNum');
    my $i = 0;
    my @pl_id = map { $_->id() } @{$self->players()};
    for (@{$data->{regions}}) {
        assert(!defined $_->{owner} || $_->{owner} ~~ @pl_id,
               'badRegions', 'badOwner' => $_->{owner},
               'gamePlayers' => [@pl_id]);
        $self->map()->regions()->[$i++]->load_state($_, $self);
    }
}

# should be loaded: $self->map
#                   $self->players
sub _load_attacks_history_from_state {
    my ($self, $data) = @_;
    my $err = 'badAttacksHistory';
    my $hist = $data->{attacksHistory};
    assert(ref($hist) eq 'ARRAY', $err, descr => 'notArray');
    my @res;
    for my $h_item (@{$hist}) {
        assert(ref($h_item) eq 'HASH', $err,
               notHash => $h_item);
        my $num = sub { defined $_[0] && $_[0] =~ /^\d+$/ };
        my $r = $h_item->{region};

        assert( $num->($r) &&
                0 <= $r && $r <= @{$self->map()->regions()},
                $err, badRegion => $r );
        assert( $num->($h_item->{tokensNum}), $err,
                badTokensNum => $h_item->{tokensNum} );
        my $is_who = sub {
            my ($player) = @_;
            $player->id() eq $h_item->{whom}
        };
        my $p = $h_item->{whom};
        if (defined $h_item->{whom}) {
            ($p) = grep { $is_who->($_) } @{$self->players()};
            assert($p, $err, badDefender => $data->{whom});
        }
        push @res, {
          region => $self->map()->get_region($r),
          tokensNum => $h_item->{tokensNum},
          whom => $p
        }
    }

    $self->history(\@res)
}

# should be loaded: $self->map
#                   $self->players
sub _load_race_state_storage_from_state{
    my ($s, $data) = @_;
    my $res = {};
    $res->{dragonAttacked} = bool($data->{dragonAttacked});
    $res->{enchanted} = bool($data->{enchanted});
    $res->{gotWealthy} = bool($data->{gotWealthy});
    $res->{declineRequested} = bool($data->{declineRequested});
    # TODO:
    # $res->{stoutStatistcs} = $data->{stoutStatistcs};
    {
        no warnings;
        $res->{berserkDice} = defined ($_ = $data->{berserkDice}) ?
                                  int $_ : undef;
        $res->{holesPlaced} = defined ($_ = $data->{holesPlaced}) ?
                                  int $_ : undef;
    }

    if (($_ = $data->{friendInfo})) {
        my $players_ids = [ map { $_->id() } @{$s->players()} ];
        assert($_->{diplomatId} ~~ $players_ids, 'badDiplomatId');
        assert($_->{friendId} ~~ $players_ids, 'badFriendId');
        $res->{friendInfo} = $data->{friendInfo}
    }
    $s->raceStateStorage($res)
}

sub load_state {
    my ($self, $data) = @_;

    # FIXME: provide more explicit sollution
    # if !defined $self->id() => we construct game object from AI
    # not for storing in db
    my $skip_validations = !defined $self->gameId();
    if (!$skip_validations) {
        die 'bad map id' if $data->{mapId} ne $self->map()->prev_id();
    }

    my @st = qw(conquer redeployed defend declined finished);
    assert(($data->{state} ~~ @st), 'badState');
    $self->state($data->{state});
    assert((defined $data->{turn} && $data->{turn} =~ /\d+/ &&
            $data->{turn} <= $self->map()->turnsNum()),
           'badTurn', turn => $data->{turn});
    $self->turn($data->{turn});
    eval{ $self->raceSelected(int $data->{raceSelected}) };
    assert( !$@, 'badRaceSelected' );

    eval{ $self->features($data->{features}) if $data->{features} };
    assert( !$@, 'badFeatures' );

    eval{ $self->lastDiceValue($_) if ($_ = $data->{lastDiceValue}) };
    assert( !$@, 'badLasDiceValue' );

    $self->_load_players_from_state($data);
    $self->_load_regions_from_state($data);
    $self->_load_token_badges_from_state($data);
    $self->_load_attacks_history_from_state($data);
    $self->_load_race_state_storage_from_state($data);

    assert(defined $data->{activePlayerNum} &&
           $data->{activePlayerNum} =~ /^\d+$/,
           'badActivePlayerNum');
    $self->activePlayerNum($data->{activePlayerNum});
}


__PACKAGE__->meta->make_immutable;
