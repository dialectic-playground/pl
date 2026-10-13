# End-to-end unit tests of DP::Hello::run, the pure core of dp-hello (FR-01 ... FR-11).

use strict;
use warnings;

use Test::More;

use DP::Hello           qw(run);
use DP::Hello::Messages qw(help_text version_text);

our $VERSION = '1.0.0';

my $HINT = "Try 'dp-hello --help' for more information.\n";

sub succeeds {
    my ( $args, $stdout, $name ) = @_;
    return is_deeply [ run( @{$args} ) ], [ $stdout, q{}, 0 ], $name;
}

sub fails {
    my ( $args, $message, $name ) = @_;
    return is_deeply [ run( @{$args} ) ], [ q{}, "dp-hello: $message\n$HINT", 2 ], $name;
}

succeeds [],                        "Hello, World!\n",      'FR-01 default greeting';
succeeds [qw(--name Ada)],          "Hello, Ada!\n",        'FR-02 --name';
succeeds [ '-n', "Zo\xC3\xAB" ],    "Hello, Zo\xC3\xAB!\n", 'FR-02 UTF-8 name';
succeeds [qw(--count 3)],           "Hello, World!\n" x 3,  'FR-04 --count';
succeeds [qw(-c2 -nKen)],           "Hello, Ken!\n" x 2,    'FR-04 bundled';
succeeds [qw(-c 007)],              "Hello, World!\n" x 7,  'FR-04 leading zeros';
succeeds [qw(-n A -n B)],           "Hello, B!\n",          'FR-06 last wins';
succeeds [ qw(-n), q{}, qw(-n B) ], "Hello, B!\n",          'FR-06 only the winner is validated';
succeeds ['--help'],                help_text(),            'FR-07 help';
succeeds [qw(--help extra -x)],     help_text(),            'FR-07 help before errors';
succeeds [qw(extra --help)],        help_text(),            'FR-07 help beats operands';
succeeds [qw(--count 0 --help)],    help_text(),            'CONV-12 help beats value errors';
succeeds ['--version'],             version_text(),         'FR-08 version';

fails [ '--name', q{} ], q{invalid argument '' for '--name'},             'FR-03 empty --name';
fails [ '-n', q{} ],     q{invalid argument '' for '-n'},                 'FR-03 empty -n';
fails [qw(--count 0)],   q{invalid argument '0' for '--count'},           'FR-05 zero';
fails [qw(-c abc)],      q{invalid argument 'abc' for '-c'},              'FR-05 non-digits';
fails [qw(-c 1001)],     q{invalid argument '1001' for '-c'},             'FR-05 too large';
fails ['extra'],         q{extra operand 'extra'},                        'FR-09 operand';
fails [qw(-- -n)],       q{extra operand '-n'},                           'FR-09 after --';
fails ['-x'],            q{invalid option -- 'x'},                        'FR-10 unknown short';
fails [qw(--nme Ada)],   q{unrecognized option '--nme'},                  'FR-10 unknown long';
fails ['--name'],        q{option '--name' requires an argument},         'FR-10 missing value';
fails ['--version=1'],   q{option '--version' doesn't allow an argument}, 'FR-10 =value';
fails [qw(-x --help)],   q{invalid option -- 'x'}, 'CONV-12 syntax error first';

done_testing;
