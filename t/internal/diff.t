use warnings;
use strict;

use Test::More;

use lib '..';
use Tester::Diff ();

sub comp { Tester::Diff::compare(@_)->errors_report(0) }


is( comp(undef, undef), '' );

is( comp(1, 1), '');
is( comp(1, 2), ': 1 vs 2');
is( comp(undef, undef), '');
is( comp(undef, 1), ': undef vs 1');
is( comp(1, undef), ': 1 vs undef');
is( comp('hello', 'hello'), '');

is( comp([], []), '');
is( comp([], 1), ': ARRAY vs scalar');
is( comp([], undef), ': ARRAY vs undef');
is( comp(undef, []), ': undef vs ARRAY');
is( comp([1], [1]), '');
is( comp([1, 2], [1, 2]), '');
is( comp([1, 2, 3], [1, 2]), '[2]: 3 vs undef');
is( comp([1, 2], [1, 2, 3]), ': array length 2 != 3');
is( comp([1], [2]), '[0]: 1 vs 2');
is( comp([undef], [undef]), '');
is( comp([undef], [1]), '[0]: undef vs 1');
is( comp([1], [undef]), '[0]: 1 vs undef');
is( comp(['hello'], ['hello']), '');

is( comp({}, {}), '');
is( comp({}, 1), ': HASH vs scalar');
is( comp({}, undef), ': HASH vs undef');
is( comp(undef, {}), ': undef vs HASH');
is( comp([], {}), ': ARRAY vs HASH');
is( comp({}, []), ': HASH vs ARRAY');
is( comp({1 => 1}, {1 => 1}), '');
is( comp({1 => 1}, {1 => 2}), '{1}: 1 vs 2');
is( comp({1 => undef}, {1 => undef}), '');
is( comp({1 => undef}, {1 => 1}), '{1}: undef vs 1');
is( comp({1 => 1}, {1 => undef}), '{1}: 1 vs undef');
is( comp({1 => 'hello'}, {1 => 'hello'}), '');

is( comp({1 => 1, 2 => 2}, {1 => 1}), '{2}: 2 vs undef');
is( comp({1 => 1}, {1 => 1, 2 => 2}), '');
is( comp({1 => 1}, {1 => 1, 2 => 2}, 'EXACT'), '{2}: undef vs 2');
is( comp({1 => 1}, {1 => 1, 2 => 2, 3 => 3}, 'EXACT'),
    "{2}: undef vs 2\n{3}: undef vs 3");

is( comp({1 => [1, 2]}, {1 => [1, 2]}), '');
is( comp({1 => [1, 2]}, {1 => [1, 2]}), '');

is( comp({1 => [1, 2]}, sub { 1 }), '');
is( comp({1 => [1, 2]}, sub { 0 }), ': exec sub');
is( comp({1 => [1, 2]}, sub { $_[1]->{msg} = 'hello', 0 }), ': hello');

# TODO: create more complex examples
# ...

done_testing();
