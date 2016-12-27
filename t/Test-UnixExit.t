#!perl

use strict;
use warnings;
use Test::More tests => 3;
use Test::UnixExit;

can_ok( 'Test::UnixExit', 'exit_ok' );
ok( defined &exit_ok, 'exit_ok exported by default' );

#diag("Testing Test::UnixExit $Test::UnixExit::VERSION, Perl $], $^X");

system( $^X, '-e', 'exit 0' );
exit_ok( $?, 0, "exits ok" );

# Simulate other conditions as putting needless corefiles on smoke test
# boxes isn't very nice, and signal handling can get a bit tricky. Add
# real tests if this simulation turns out to be a problem.
my $status = pack "s", 0;

# TODO
