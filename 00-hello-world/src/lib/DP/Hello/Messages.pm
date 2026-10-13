package DP::Hello::Messages;

# Fixed texts of dp-hello: help (user manual "Help output", CONV-23), version (CONV-02), and
# the single mapping from internal usage errors to CONV-13/CONV-14 diagnostics.

use strict;
use warnings;

use Exporter qw(import);

our $VERSION   = '1.0.0';
our @EXPORT_OK = qw(help_text version_text usage_diagnostic);

my $TOOL = 'dp-hello';

my $HELP_TEXT = <<'END_HELP';
Usage: dp-hello [OPTION]...
Print a greeting to standard output.

Options:
  -n, --name=NAME     greet NAME instead of World
  -c, --count=COUNT   print the greeting COUNT times (1-1000, default 1)
      --help          display this help and exit
      --version       output version information and exit
END_HELP

my $VERSION_TEXT = "$TOOL (dialectic-playground) 1.0.0\n";

# Error kind -> function of the error's details returning the CONV-13 message.
my %MESSAGES = (
    invalid_option          => sub { "invalid option -- '$_[0]{letter}'" },
    unrecognized_option     => sub { "unrecognized option '$_[0]{option}'" },
    short_requires_argument => sub { "option requires an argument -- '$_[0]{letter}'" },
    long_requires_argument  => sub { "option '$_[0]{option}' requires an argument" },
    no_argument_allowed     => sub { "option '$_[0]{option}' doesn't allow an argument" },
    invalid_argument        => sub { "invalid argument '$_[0]{value}' for '$_[0]{option}'" },
    extra_operand           => sub { "extra operand '$_[0]{operand}'" },
);

sub help_text    { return $HELP_TEXT }
sub version_text { return $VERSION_TEXT }

# usage_diagnostic(\%error) -> the two diagnostic lines (CONV-13 message, CONV-14 hint).
sub usage_diagnostic {
    my ($error) = @_;
    my $message = $MESSAGES{ $error->{kind} }->($error);
    return "$TOOL: $message\nTry '$TOOL --help' for more information.\n";
}

1;
