# -*- Perl -*-
#
# Tests exit status words

package Test::UnixExit;

use 5.006;
use strict;
use warnings;
use Carp qw(croak);
use Test::Builder;

our $VERSION = '0.01';

require Exporter;
use vars qw(@ISA @EXPORT);
@ISA    = qw(Exporter);
@EXPORT = qw(exit_is);

my $test = Test::Builder->new;
my @keys = qw(iscore issig code);

sub exit_is {
    my ( $status, $expected_value, $name ) = @_;

    croak "Usage: status expected-value test-name"
      if !defined $status
      or !defined $expected_value
      or !defined $name;

    if ( $expected_value =~ m/^[0-9]+$/ ) {
        $expected_value = { code => $expected_value };
    } elsif ( ref $expected_value ne 'HASH' ) {
        croak "expected-value must be integer or hash reference";
    }

    my %got_value;
    $got_value{code}   = $status >> 8;
    $got_value{issig}  = $status & 127;
    $got_value{iscore} = $status & 128;

    my $passed = 1;
    for my $key (@keys) {
        if ( $got_value{$key} != $expected_value{$key} || 0 ) {
            $passed = 0;
            last;
        }
    }

    $test->ok( $passed, $name );

    $test->diag(
        sprintf
          "Got:      is_core=%d is_sig=%d code=%d\nExpected: is_core=%d is_sig=%d code=%d\n",
        map( { $got_value{$_} } @keys ),
        map( { $expected_value{$_} || 0 } @keys )
    ) if !$passed;

    return $passed;
}

1;
__END__

=head1 NAME

Test::UnixExit - tests exit status words

=head1 SYNOPSIS

  #use Expect;
  #use Test::Cmd;
  #use Test::Most;
  use Test::UnixExit;

  # ... some call that sets $? here or $expect->exitstatus ...

  exit_is( $?, 0, "exited ok" );
  exit_is( $?, { ... }, "ate a SIGINT" );
  todo

=head1 DESCRIPTION

This module provides a means to check that the exit status word conforms
to a particular pattern, including whether a signal was sent and whether
a core file was generated; the simple C<$? E<gt>E<gt> 8 == 0> test
discards those last two points. This code is most useful when testing
external commands via C<system>, L<Test::Cmd>, or L<Expect>; perl code
itself may instead be tested with other modules such as L<Test::Exit> or
L<Test::Trap>.

Internally L<Test::Builder> is used, so this module might best be paired
with L<Test::Most> (and is otherwise untested with other test modules).

=head1 FUNCTION

The one function is exported by default. Sorry about that.

=over 4

=item B<exit_is> I<status-word>, I<expected-value>, I<test-name>

This function accepts a I<status-word> (the 16-bit return value from the
C<wait(2)> call), an I<expected-value> as either a integer exit code or a
hash reference with the necessary fields, and the name of the test.
Whether or not the test passed is the return value.

The fields for the hash reference are:

    code   => 8-bit exit status number
    iscore => bool whether a core file was generated
    issig  => bool whether process ate a signal

If only the integer exit code is supplied, the C<iscore> and C<issig>
are assumed to be 0, on the assumption that most calls will only be
concerned with the exit status number.

=back

=head1 BUGS

=head2 Reporting Bugs

Please report any bugs or feature requests to
C<bug-test-unixexit at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-UnixExit>.

Patches might best be applied towards:

L<https://github.com/thrig/Test-UnixExit>

=head2 Known Issues

None at this time.

=head1 SEE ALSO

L<Test::Cmd>, L<Expect> - these provide means to check external
commands, either by running the commands under a shell, or simulating a
terminal environment.

L<Test::Exit>, L<Test::Trap> - these check that Perl code behaves in
a particular way, and may be more suitable for testing code in a
module over running a wrapper via the complication of a shell or
virtual terminal.

L<wait(2)> - note that shells are different from the system call in that
the 16-bit status word is shoehorned into an 8-bit value available via
the shell C<$?> variable, which is the same name as the variable Perl
stores the 16-bit status word in. This can and does cause confusion.

=head1 AUTHOR

thrig - Jeremy Mates (cpan:JMATES) C<< <jmates at cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by Jeremy Mates

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/BSD-3-Clause>

=cut
