package Game::Roles::Power;
use Moose::Role;


requires 'power_name';

override 'tokens_cnt' => sub {
    my ($self) = @_;
    super() + $self->_power_tokens_cnt()
};


1

__END__

=pod

alchemist
berserk
bivouaking
commando
diplomat
dragonMaster
flying
forest
fortified
heroic
hill
merchant
mounted
pillaging
seafaring
stout
swamp
underworld
wealthy

=cut
