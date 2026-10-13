# Unit tests for DP::Hello::Messages (CONV-02, CONV-13 ... CONV-15, CONV-23).

use strict;
use warnings;

use Test::More;

use DP::Hello::Messages qw(help_text version_text usage_diagnostic);

our $VERSION = '1.0.0';

my $HINT = "Try 'dp-hello --help' for more information.\n";

is version_text(), "dp-hello (dialectic-playground) 1.0.0\n", 'version line';
is help_text(),
    join( q{},
    map { "$_\n" } 'Usage: dp-hello [OPTION]...',
    'Print a greeting to standard output.',
    q{},
    'Options:',
    '  -n, --name=NAME     greet NAME instead of World',
    '  -c, --count=COUNT   print the greeting COUNT times (1-1000, default 1)',
    '      --help          display this help and exit',
    '      --version       output version information and exit' ),
    'help text matches the user manual byte for byte';
unlike help_text(), qr/\r/xms, 'help is LF only';

my @cases = (
    [ { kind => 'invalid_option',      letter => 'x' },       q{invalid option -- 'x'} ],
    [ { kind => 'unrecognized_option', option => '--nme=A' }, q{unrecognized option '--nme=A'} ],
    [ { kind => 'short_requires_argument', letter => 'n' }, q{option requires an argument -- 'n'} ],
    [
        { kind => 'long_requires_argument', option => '--count' },
        q{option '--count' requires an argument}
    ],
    [
        { kind => 'no_argument_allowed', option => '--help' },
        q{option '--help' doesn't allow an argument}
    ],
    [
        { kind => 'invalid_argument', value => q{}, option => '--name' },
        q{invalid argument '' for '--name'}
    ],
    [
        { kind => 'invalid_argument', value => q{it's}, option => '-c' },
        q{invalid argument 'it's' for '-c'}
    ],
    [ { kind => 'extra_operand', operand => 'extra' }, q{extra operand 'extra'} ],
);

for my $case (@cases) {
    my ( $error, $message ) = @{$case};
    is usage_diagnostic($error), "dp-hello: $message\n$HINT", $message;
}

done_testing;
