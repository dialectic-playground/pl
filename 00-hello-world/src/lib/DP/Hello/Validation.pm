package DP::Hello::Validation;

# Validation of a parse result into a greeting configuration (FR-03 ... FR-06, FR-09).

use strict;
use warnings;

use Exporter qw(import);

our $VERSION   = '1.0.0';
our @EXPORT_OK = qw(validate validate_name validate_count);

my $DEFAULT_NAME  = 'World';
my $DEFAULT_COUNT = 1;
my $MIN_COUNT     = 1;
my $MAX_COUNT     = 1000;

# Longest digit string (after leading zeros are removed) that can still be in range.
my $MAX_COUNT_DIGITS = length $MAX_COUNT;

# validate(\%parsed) -> (\%config, undef) or (undef, \%error)
#
# Turns a 'greet' result of DP::Hello::Options::parse_args into { name => ..., count => ... }.
# Operands are rejected first (FR-09), then the winning --name and --count values (FR-06).
sub validate {
    my ($parsed) = @_;
    my @operands = @{ $parsed->{operands} };
    return ( undef, { kind => 'extra_operand', operand => $operands[0] } ) if @operands;

    my ( $name, $count ) = ( $DEFAULT_NAME, $DEFAULT_COUNT );
    my $error;
    if ( $parsed->{name} ) {
        ( $name, $error ) = validate_name( $parsed->{name} );
        return ( undef, $error ) if $error;
    }
    if ( $parsed->{count} ) {
        ( $count, $error ) = validate_count( $parsed->{count} );
        return ( undef, $error ) if $error;
    }
    return ( { name => $name, count => $count }, undef );
}

# validate_name(\%option_value) -> ($name, undef) or (undef, \%error). FR-02, FR-03.
sub validate_name {
    my ($option_value) = @_;
    return ( $option_value->{value}, undef ) if $option_value->{value} ne q{};
    return ( undef,                  _invalid_argument($option_value) );
}

# validate_count(\%option_value) -> ($count, undef) or (undef, \%error). FR-04, FR-05.
#
# Only ASCII digits are accepted (no sign, spaces, or trailing newline); leading zeros are
# removed before the length check, so arbitrarily long inputs never overflow.
sub validate_count {
    my ($option_value) = @_;
    my $text = $option_value->{value};
    return ( undef, _invalid_argument($option_value) ) if $text !~ /\A[0-9]+\z/xms;
    ( my $digits = $text ) =~ s/\A0+(?=[0-9])//xms;
    if ( length $digits <= $MAX_COUNT_DIGITS ) {
        my $count = 0 + $digits;
        return ( $count, undef ) if $count >= $MIN_COUNT && $count <= $MAX_COUNT;
    }
    return ( undef, _invalid_argument($option_value) );
}

sub _invalid_argument {
    my ($option_value) = @_;
    return {
        kind   => 'invalid_argument',
        value  => $option_value->{value},
        option => $option_value->{option},
    };
}

1;
