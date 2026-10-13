# Unit tests for DP::Hello::Options::parse_args (CONV-07 ... CONV-13, FR-02, FR-06, FR-07,
# FR-08, FR-10).

use strict;
use warnings;

use Test::More;

use DP::Hello::Options qw(parse_args);

our $VERSION = '1.0.0';

sub greet {
    my (%expected) = @_;
    return {
        action   => 'greet',
        name     => $expected{name},
        count    => $expected{count},
        operands => $expected{operands} || [],
    };
}

sub value {
    my ( $value, $option ) = @_;
    return { value => $value, option => $option };
}

sub error {
    my ( $kind, %details ) = @_;
    return { error => { kind => $kind, %details } };
}

subtest 'no arguments' => sub {
    is_deeply parse_args(), greet(), 'defaults are left to validation';
};

subtest 'name forms' => sub {
    my $ada = value( 'Ada', '--name' );
    is_deeply parse_args(qw(--name Ada)), greet( name => $ada ),                     '--name NAME';
    is_deeply parse_args(qw(--name=Ada)), greet( name => $ada ),                     '--name=NAME';
    is_deeply parse_args(qw(-n Ada)),     greet( name => value( 'Ada', '-n' ) ),     '-n NAME';
    is_deeply parse_args(qw(-nAda)),      greet( name => value( 'Ada', '-n' ) ),     '-nNAME';
    is_deeply parse_args('--name=a=b'),   greet( name => value( 'a=b', '--name' ) ), 'value with =';
    is_deeply parse_args('--name='),      greet( name => value( q{}, '--name' ) ), 'empty attached';
    is_deeply parse_args( '-n', q{} ),    greet( name => value( q{}, '-n' ) ), 'empty separate';
    is_deeply parse_args( '--name', 'Ada Lovelace' ),
        greet( name => value( 'Ada Lovelace', '--name' ) ), 'spaces preserved';
};

subtest 'values beginning with a dash' => sub {
    is_deeply parse_args('--name=-x'),   greet( name => value( '-x', '--name' ) ), '--name=-x';
    is_deeply parse_args('-n-x'),        greet( name => value( '-x', '-n' ) ),     '-n-x';
    is_deeply parse_args(qw(--name -x)), greet( name => value( '-x', '--name' ) ), '--name -x';
    is_deeply parse_args(qw(-n --help)), greet( name => value( '--help', '-n' ) ),
        'a separate value is consumed even if it looks like an option';
};

subtest 'bundling (CONV-07)' => sub {
    is_deeply parse_args(qw(-c2 -nKen)),
        greet( name => value( 'Ken', '-n' ), count => value( '2', '-c' ) ), '-c2 -nKen';
    is_deeply parse_args('-cn'), greet( count => value( 'n', '-c' ) ),
        'a valued option consumes the rest of the token';
};

subtest 'count forms' => sub {
    is_deeply parse_args(qw(--count 3)), greet( count => value( '3', '--count' ) ), '--count N';
    is_deeply parse_args('--count=3'),   greet( count => value( '3', '--count' ) ), '--count=N';
    is_deeply parse_args(qw(-c 3)),      greet( count => value( '3', '-c' ) ),      '-c N';
    is_deeply parse_args(qw(--count 0)), greet( count => value( '0', '--count' ) ),
        'values are recorded, not validated';
};

subtest 'last occurrence wins (CONV-11)' => sub {
    is_deeply parse_args(qw(-n A -n B)), greet( name => value( 'B', '-n' ) ), '-n A -n B';
    is_deeply parse_args(qw(-n A --name=B)), greet( name => value( 'B', '--name' ) ),
        'the winner keeps its own spelling';
    is_deeply parse_args(qw(-c 0 -c 2)), greet( count => value( '2', '-c' ) ),
        'an invalid earlier value is overridden';
};

subtest 'operands and terminator (CONV-09, CONV-10)' => sub {
    is_deeply parse_args('extra'),   greet( operands => ['extra'] ), 'operand';
    is_deeply parse_args('-'),       greet( operands => ['-'] ),     'a lone dash is an operand';
    is_deeply parse_args(qw(-- -n)), greet( operands => ['-n'] ),    'tokens after -- are operands';
    is_deeply parse_args(qw(-- --help)), greet( operands => ['--help'] ), '-- --help';
    is_deeply parse_args(qw(a -n X b)),
        greet( name => value( 'X', '-n' ), operands => [qw(a b)] ), 'interleaved';
    is_deeply parse_args(qw(-- --)), greet( operands => ['--'] ), 'a second -- is an operand';
};

subtest 'help and version (CONV-12)' => sub {
    is_deeply parse_args('--help'),             { action => 'help' },    '--help';
    is_deeply parse_args('--version'),          { action => 'version' }, '--version';
    is_deeply parse_args(qw(--help extra -x)),  { action => 'help' },    'the scan stops at --help';
    is_deeply parse_args(qw(extra --help)),     { action => 'help' },    'operands come later';
    is_deeply parse_args(qw(--count 0 --help)), { action => 'help' },    'values come later';
    is_deeply parse_args(qw(--version --help)), { action => 'version' }, 'the first one wins';
    is_deeply parse_args(qw(-x --help)), error( 'invalid_option', letter => 'x' ),
        'an earlier syntax error wins';
};

subtest 'syntax errors (CONV-13)' => sub {
    is_deeply parse_args('-x'), error( 'invalid_option', letter => 'x' ), '-x';
    is_deeply parse_args('-xn'), error( 'invalid_option', letter => 'x' ),
        'first letter of a bundle';
    is_deeply parse_args("-\xC3\xAB"), error( 'invalid_option', letter => "\xC3\xAB" ),
        'a non-ASCII letter is a whole UTF-8 character';
    is_deeply parse_args('--nme'), error( 'unrecognized_option', option => '--nme' ), '--nme';
    is_deeply parse_args('--nam'), error( 'unrecognized_option', option => '--nam' ),
        'no abbreviations (CONV-08)';
    is_deeply parse_args('--nme=Ada'), error( 'unrecognized_option', option => '--nme=Ada' ),
        'the full token is reported';
    is_deeply parse_args('--'), greet(), 'a lone -- is fine';
    is_deeply parse_args('---'), error( 'unrecognized_option', option => '---' ), '---';
    is_deeply parse_args('--name'), error( 'long_requires_argument', option => '--name' ),
        '--name without a value';
    is_deeply parse_args('--count'), error( 'long_requires_argument', option => '--count' ),
        '--count without a value';
    is_deeply parse_args('-n'), error( 'short_requires_argument', letter => 'n' ), '-n alone';
    is_deeply parse_args('-c'), error( 'short_requires_argument', letter => 'c' ), '-c alone';
    is_deeply parse_args('--help=1'), error( 'no_argument_allowed', option => '--help' ),
        '--help=1';
    is_deeply parse_args('--version='), error( 'no_argument_allowed', option => '--version' ),
        '--version= (empty value)';
    is_deeply parse_args(qw(extra -x)), error( 'invalid_option', letter => 'x' ),
        'syntax errors beat operands';
};

done_testing;
