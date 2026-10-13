# Unit tests for DP::Hello::Validation (FR-03 ... FR-06, FR-09).

use strict;
use warnings;

use Test::More;

use DP::Hello::Validation qw(validate validate_name validate_count);

our $VERSION = '1.0.0';

sub parsed {
    my (%fields) = @_;
    return { action => 'greet', operands => [], %fields };
}

sub invalid {
    my ( $value, $option ) = @_;
    return { kind => 'invalid_argument', value => $value, option => $option };
}

subtest 'defaults' => sub {
    my ( $config, $error ) = validate( parsed() );
    is_deeply $config, { name => 'World', count => 1 }, 'World, once';
    is $error, undef, 'no error';
};

subtest 'name' => sub {
    is_deeply [ validate_name( { value => 'Zoë', option => '-n' } ) ], [ 'Zoë', undef ],
        'non-ASCII name';
    is_deeply [ validate_name( { value => ' ', option => '-n' } ) ], [ q{ }, undef ],
        'a space is not empty';
    is_deeply [ validate_name( { value => q{}, option => '-n' } ) ],
        [ undef, invalid( q{}, '-n' ) ], 'empty name with -n';
    is_deeply [ validate_name( { value => q{}, option => '--name' } ) ],
        [ undef, invalid( q{}, '--name' ) ], 'empty name with --name';
};

subtest 'count boundaries' => sub {
    my %valid = ( '1' => 1, '2' => 2, '1000' => 1000, '007' => 7, '0001000' => 1000 );
    for my $text ( sort keys %valid ) {
        is_deeply [ validate_count( { value => $text, option => '-c' } ) ],
            [ $valid{$text}, undef ], "'$text' is valid";
    }
    for my $text ( '0', '000', '1001', '99999999999999999999999', q{}, 'abc', '-1', '+1', ' 1',
        '1 ', "1\n", '1.0', '1e2', "\xD9\xA1" )
    {
        is_deeply [ validate_count( { value => $text, option => '--count' } ) ],
            [ undef, invalid( $text, '--count' ) ], "'$text' is invalid";
    }
};

subtest 'operands are rejected first' => sub {
    my ( $config, $error ) = validate(
        parsed(
            operands => [qw(a b)],
            name     => { value => q{}, option => '-n' },
        )
    );
    is $config, undef, 'no config';
    is_deeply $error, { kind => 'extra_operand', operand => 'a' }, 'the first operand';
};

subtest 'name is checked before count' => sub {
    my ( undef, $error ) = validate(
        parsed(
            name  => { value => q{}, option => '--name' },
            count => { value => '0', option => '-c' },
        )
    );
    is_deeply $error, invalid( q{}, '--name' ), 'empty name reported';
};

subtest 'valid configuration' => sub {
    my ( $config, $error ) = validate(
        parsed(
            name  => { value => 'Ken', option => '-n' },
            count => { value => '2',   option => '-c' },
        )
    );
    is_deeply $config, { name => 'Ken', count => 2 }, 'Ken, twice';
    is $error, undef, 'no error';
};

done_testing;
