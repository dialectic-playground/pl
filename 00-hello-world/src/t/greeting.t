# Unit tests for the pure greeting construction in DP::Hello::Greeting (NFR-05).

use strict;
use warnings;

use Test::More;

use DP::Hello::Greeting qw(greeting_line greeting_text);

our $VERSION = '1.0.0';

is greeting_line('World'),            "Hello, World!\n",            'default greeting';
is greeting_line('Ada Lovelace'),     "Hello, Ada Lovelace!\n",     'spaces preserved';
is greeting_line("Zo\xC3\xAB"),       "Hello, Zo\xC3\xAB!\n",       'UTF-8 bytes preserved';
is greeting_line('-x'),               "Hello, -x!\n",               'leading dash preserved';
is greeting_text( 'Ken', 1 ),         "Hello, Ken!\n",              'one line';
is greeting_text( 'Ken', 3 ),         "Hello, Ken!\n" x 3,          'three lines';
is greeting_text( 'Ken', 0 ),         q{},                          'zero lines';
is length greeting_text( 'A', 1000 ), 1000 * length("Hello, A!\n"), '1000 lines';
unlike greeting_text( 'A', 5 ), qr/\r/xms, 'LF only';

done_testing;
