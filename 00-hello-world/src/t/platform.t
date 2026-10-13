# Unit tests for DP::Hello::Platform (CONV-05).

use strict;
use warnings;

use Test::More;

use DP::Hello::Platform qw(command_line_arguments from_code_page);

our $VERSION = '1.0.0';

my $ZOE_UTF8 = "Zo\xC3\xAB";

is_deeply [ from_code_page( 1252, "Zo\xEB", 'Ada' ) ], [ $ZOE_UTF8, 'Ada' ],
    'cp1252 is converted to UTF-8';
is_deeply [ from_code_page( 1251, "\xC0\xE4\xE0" ) ], ["\xD0\x90\xD0\xB4\xD0\xB0"],
    'cp1251 is converted to UTF-8';
is_deeply [ from_code_page( 65_001, $ZOE_UTF8 ) ], [$ZOE_UTF8], 'UTF-8 code page unchanged';
is_deeply [ from_code_page( 1,      'x' ) ],       ['x'],       'unknown code page unchanged';

SKIP: {
    skip 'POSIX pass-through', 1 if $^O eq 'MSWin32';
    is_deeply [ command_line_arguments( $ZOE_UTF8, "\xFF" ) ], [ $ZOE_UTF8, "\xFF" ],
        'POSIX arguments are passed through byte for byte';
}

done_testing;
