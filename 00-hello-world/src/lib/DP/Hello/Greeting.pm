package DP::Hello::Greeting;

# Pure greeting construction (FR-01, FR-02, FR-04, NFR-05).

use strict;
use warnings;

use Exporter qw(import);

our $VERSION   = '1.0.0';
our @EXPORT_OK = qw(greeting_line greeting_text);

# greeting_line($name) -> "Hello, $name!\n" (the name is used verbatim, LF only).
sub greeting_line {
    my ($name) = @_;
    return "Hello, $name!\n";
}

# greeting_text($name, $count) -> $count greeting lines (empty when $count is 0 or less).
sub greeting_text {
    my ( $name, $count ) = @_;
    return $count > 0 ? greeting_line($name) x $count : q{};
}

1;
