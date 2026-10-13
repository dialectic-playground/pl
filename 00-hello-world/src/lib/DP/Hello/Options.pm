package DP::Hello::Options;

# Command-line parsing for dp-hello (CONV-07 ... CONV-12, SRS section 3.2).
#
# The parser is hand-written: Getopt::Long's diagnostics and abbreviation rules differ from
# CONV-08 and CONV-13. It only recognizes the syntax; option values are checked afterwards by
# DP::Hello::Validation, so value errors never take precedence over --help (CONV-12).

use strict;
use warnings;

use Exporter qw(import);

our $VERSION   = '1.0.0';
our @EXPORT_OK = qw(parse_args);

# Options that take a value: short letter / long name -> the field they set.
my %SHORT_VALUED = ( n    => 'name', c     => 'count' );
my %LONG_VALUED  = ( name => 'name', count => 'count' );

# Options that take no value and end the scan.
my %LONG_FLAGS = ( help => 'help', version => 'version' );

# One character of a short-option token: a complete UTF-8 sequence, or else a single byte, so
# a diagnostic such as "invalid option -- 'ë'" never splits a character (CONV-05).
my $CHARACTER = qr/[\xC2-\xF4][\x80-\xBF]{1,3}|./xms;

# parse_args(@args) -> \%result
#
# Scans the arguments (UTF-8 byte strings, without the program name) from left to right.
# Returns { action => 'help' } or { action => 'version' } as soon as --help or --version is
# reached, { error => \%error } for the first option syntax error met before that, and
# otherwise { action => 'greet', name => $value, count => $value, operands => \@operands },
# where each $value is undef or { value => ..., option => '-n' | '--name' | ... } and the last
# occurrence of an option wins (CONV-11).
sub parse_args {
    my (@args) = @_;
    my %values;
    my @operands;
    while (@args) {
        my $token = shift @args;
        if ( $token eq q{--} ) {    # CONV-09: everything after it is an operand
            push @operands, @args;
            last;
        }
        if ( $token =~ /\A--/xms ) {
            my $result = _parse_long( $token, \@args, \%values );
            return $result if $result;
        }
        elsif ( $token =~ /\A-./xms ) {
            my $result = _parse_short( $token, \@args, \%values );
            return $result if $result;
        }
        else {                      # CONV-10: operands (including "-") are only collected here
            push @operands, $token;
        }
    }
    return {
        action   => 'greet',
        name     => $values{name},
        count    => $values{count},
        operands => \@operands,
    };
}

# Handles one --long[=value] token (CONV-08). Returns a result that ends the scan, or undef.
sub _parse_long {
    my ( $token, $args, $values ) = @_;
    my ( $name, $inline ) = $token =~ /\A--([^=]*)(?:=(.*))?\z/xms;
    if ( exists $LONG_FLAGS{$name} ) {
        return _error( 'no_argument_allowed', option => "--$name" ) if defined $inline;
        return { action => $LONG_FLAGS{$name} };
    }
    return _error( 'unrecognized_option', option => $token ) if !exists $LONG_VALUED{$name};
    my $value = $inline;
    if ( !defined $value ) {
        return _error( 'long_requires_argument', option => "--$name" ) if !@{$args};
        $value = shift @{$args};
    }
    $values->{ $LONG_VALUED{$name} } = { value => $value, option => "--$name" };
    return;
}

# Handles one -x... token (CONV-07). Both short options take a value, which is the rest of the
# token or, when that is empty, the next argument. Returns an error result, or undef.
sub _parse_short {
    my ( $token, $args, $values ) = @_;
    my ( $letter, $attached ) = $token =~ /\A-($CHARACTER)(.*)\z/xms;
    return _error( 'invalid_option', letter => $letter ) if !exists $SHORT_VALUED{$letter};
    my $value = $attached;
    if ( $value eq q{} ) {
        return _error( 'short_requires_argument', letter => $letter ) if !@{$args};
        $value = shift @{$args};
    }
    $values->{ $SHORT_VALUED{$letter} } = { value => $value, option => "-$letter" };
    return;
}

sub _error {
    my ( $kind, %details ) = @_;
    return { error => { kind => $kind, %details } };
}

1;
