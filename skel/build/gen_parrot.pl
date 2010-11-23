#! perl
# Copyright (C) 2009 The Perl Foundation

=head1 TITLE

gen_parrot.pl - script to obtain and build Parrot for Rakudo

=head2 SYNOPSIS

    perl gen_parrot.pl [--parrot --configure=options]

=head2 DESCRIPTION

Maintains an appropriate copy of Parrot in the parrot/ subdirectory.
The revision of Parrot to be used in the build is given by the
build/PARROT_REVISION file.

=cut

use strict;
use warnings;
use 5.008;

#  Work out slash character to use.
my $slash = $^O eq 'MSWin32' ? '\\' : '/';

chdir('parrot-2.10.1') || die "Can't chdir to 'parrot-2.10.1': $!";

##  If we have a Makefile from a previous build, do a 'make realclean'
if (-f 'Makefile') {
    my %config = read_parrot_config();
    my $make = $config{'make'};
    if ($make) {
        print "\nPerforming '$make realclean' ...\n";
        system_or_die($make, "realclean");
    }
}

print "\nConfiguring Parrot ...\n";
my @config_command = ($^X, 'Configure.pl', @ARGV);
print "@config_command\n";
system_or_die( @config_command );

print "\nBuilding Parrot ...\n";
my %config = read_parrot_config();
my $make = $config{'make'} or exit(1);
system_or_die($make, 'install-dev');

sub read_parrot_config {
    my %config = ();
    if (open my $CFG, "config_lib.pir") {
        while (<$CFG>) {
            if (/P0\["(.*?)"], "(.*?)"/) { $config{$1} = $2 }
        }
        close $CFG;
    }
    %config;
}
    
sub system_or_die {
    my @cmd = @_;

    system( @cmd ) == 0
        or die "Command failed (status $?): @cmd\n";
}
