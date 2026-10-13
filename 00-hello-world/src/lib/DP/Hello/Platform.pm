package DP::Hello::Platform;

# Command-line arguments as UTF-8 bytes on every operating system (CONV-05).
#
# POSIX: the arguments already are the user's bytes, interpreted as UTF-8, and pass through
# unchanged. Windows: perl.exe receives its arguments from the C runtime, which converts the
# UTF-16 command line to the active ANSI code page (for example cp1252); they are decoded from
# that code page here and re-encoded as UTF-8, using only core modules (Win32, Encode).

use strict;
use warnings;

use Encode   qw(encode find_encoding);
use Exporter qw(import);

our $VERSION   = '1.0.0';
our @EXPORT_OK = qw(command_line_arguments from_code_page);

my $UTF8_CODE_PAGE = 65_001;

# command_line_arguments(@ARGV) -> the arguments as UTF-8 byte strings.
sub command_line_arguments {
    my (@arguments) = @_;
    return @arguments if $^O ne 'MSWin32';
    my $code_page = eval {
        require Win32;
        Win32::GetACP();
    };
    return @arguments if !$code_page;
    return from_code_page( $code_page, @arguments );
}

# from_code_page($code_page, @arguments) -> the arguments, decoded from Windows code page
# $code_page and encoded as UTF-8. Arguments are returned unchanged when the code page is
# already UTF-8, or unknown to Encode.
sub from_code_page {
    my ( $code_page, @arguments ) = @_;
    return @arguments if $code_page == $UTF8_CODE_PAGE;
    my $encoding = find_encoding("cp$code_page");
    return @arguments if !$encoding;
    return map { encode( 'UTF-8', $encoding->decode($_) ) } @arguments;
}

1;
