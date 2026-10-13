package DP::Hello;

# dp-hello: print a greeting to standard output (curriculum project 00-hello-world).
#
# One module per responsibility (SRS NFR-04):
#   DP::Hello::Options     command-line parsing (CONV-07 ... CONV-12)
#   DP::Hello::Validation  option-value and operand validation (FR-03, FR-05, FR-09)
#   DP::Hello::Greeting    pure greeting construction (FR-01, FR-02, FR-04, NFR-05)
#   DP::Hello::Messages    help, version, and CONV-13/CONV-14 diagnostics
#   DP::Hello::Output      binary, LF-only output (CONV-03, CONV-25)
#   DP::Hello::Platform    UTF-8 command-line arguments on every OS (CONV-05)
# This module wires them together: run() is pure, main() is the thin I/O shell around it.

use strict;
use warnings;

use Exporter qw(import);

use DP::Hello::Greeting   qw(greeting_text);
use DP::Hello::Messages   qw(help_text version_text usage_diagnostic);
use DP::Hello::Options    qw(parse_args);
use DP::Hello::Output     qw(binary_streams write_bytes);
use DP::Hello::Platform   qw(command_line_arguments);
use DP::Hello::Validation qw(validate);

our $VERSION   = '1.0.0';
our @EXPORT_OK = qw(run main);

my $EXIT_SUCCESS = 0;
my $EXIT_FAILURE = 1;
my $EXIT_USAGE   = 2;

# run(@args) -> ($stdout, $stderr, $status)
#
# The whole behavior of dp-hello for UTF-8 byte-string arguments (without the program name),
# with no I/O: exactly one of $stdout and $stderr is non-empty.
sub run {
    my (@args) = @_;
    my $parsed = parse_args(@args);
    return ( q{}, usage_diagnostic( $parsed->{error} ), $EXIT_USAGE ) if $parsed->{error};
    return ( help_text(),    q{}, $EXIT_SUCCESS ) if $parsed->{action} eq 'help';
    return ( version_text(), q{}, $EXIT_SUCCESS ) if $parsed->{action} eq 'version';
    my ( $config, $error ) = validate($parsed);
    return ( q{}, usage_diagnostic($error),                           $EXIT_USAGE ) if $error;
    return ( greeting_text( $config->{name}, $config->{count} ), q{}, $EXIT_SUCCESS );
}

# main(@ARGV) -> exit status. Runs dp-hello against the real process streams.
sub main {
    my (@argv) = @_;
    binary_streams();
    my ( $stdout, $stderr, $status ) = run( command_line_arguments(@argv) );
    return $EXIT_FAILURE if !write_bytes( \*STDOUT, $stdout );    # EPIPE (CONV-25)
    write_bytes( \*STDERR, $stderr );
    return $status;
}

1;
