# Tests of the dp-hello launcher as a separate process: binary (LF-only) output on every OS,
# exit statuses, and empty streams (CONV-03, CONV-14, FR-11).

use strict;
use warnings;

use Test::More;

use File::Spec ();
use FindBin    ();
use IPC::Open3 qw(open3);
use Symbol     qw(gensym);

our $VERSION = '1.0.0';

my $LAUNCHER = File::Spec->catfile( $FindBin::RealBin, File::Spec->updir, 'bin', 'dp-hello' );

sub slurp_raw {
    my ($handle) = @_;
    binmode $handle, ':raw';
    local $/ = undef;
    my $bytes = <$handle>;
    return $bytes // q{};
}

# Runs the launcher with the current perl; returns (stdout bytes, stderr bytes, exit status).
# The outputs are far smaller than a pipe buffer, so reading them one after the other is safe.
sub launch {
    my (@args)        = @_;
    my $stderr_handle = gensym;
    my $pid = open3( my $stdin_handle, my $stdout_handle, $stderr_handle, $^X, $LAUNCHER, @args );
    close $stdin_handle or die "close stdin: $!\n";
    my $stdout = slurp_raw($stdout_handle);
    my $stderr = slurp_raw($stderr_handle);
    waitpid $pid, 0;
    return ( $stdout, $stderr, $? >> 8 );
}

is_deeply [ launch() ],                [ "Hello, World!\n", q{}, 0 ], 'default greeting, LF only';
is_deeply [ launch(qw(-c 2 -n Ada)) ], [ "Hello, Ada!\nHello, Ada!\n", q{}, 0 ], 'repetition';
is_deeply [ launch('-x') ],
    [ q{}, "dp-hello: invalid option -- 'x'\nTry 'dp-hello --help' for more information.\n", 2 ],
    'usage error on stderr, LF only, exit 2';

# Windows: perl passes the arguments through the ANSI code page, so on a cp1252 system the byte
# "\xEB" arrives as UTF-16 "ë" and dp-hello must print its UTF-8 encoding (CONV-05).
my $windows_code_page = $^O eq 'MSWin32'   ? eval { require Win32; Win32::GetACP() } : undef;
my $name              = $windows_code_page ? "Zo\xEB"                                : "Zo\xC3\xAB";
SKIP: {
    skip "ANSI code page $windows_code_page is not cp1252", 1
        if $windows_code_page && $windows_code_page != 1252;
    is_deeply [ launch( '-n', $name ) ], [ "Hello, Zo\xC3\xAB!\n", q{}, 0 ],
        'a non-ASCII name is printed as UTF-8';
}

done_testing;
