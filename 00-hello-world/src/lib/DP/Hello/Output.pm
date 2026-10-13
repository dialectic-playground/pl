package DP::Hello::Output;

# Byte-exact output (CONV-03, CONV-25): standard output and standard error are switched to
# the :raw layer, so Perl never translates LF into CRLF (Windows) and never re-encodes text.

use strict;
use warnings;

use Exporter qw(import);

our $VERSION   = '1.0.0';
our @EXPORT_OK = qw(binary_streams write_bytes);

# binary_streams() switches STDOUT and STDERR to binary mode.
sub binary_streams {
    binmode STDOUT, ':raw';
    binmode STDERR, ':raw';
    return;
}

# write_bytes($handle, $bytes) -> true if every byte was written and flushed.
#
# A reader that has gone away (EPIPE) makes the write fail; the caller then exits quietly
# (CONV-25). On POSIX, SIGPIPE terminates the process first, which is equally quiet.
sub write_bytes {
    my ( $handle, $bytes ) = @_;
    return 1 if $bytes eq q{};
    my $written = print {$handle} $bytes;
    return $written && $handle->flush;
}

1;
