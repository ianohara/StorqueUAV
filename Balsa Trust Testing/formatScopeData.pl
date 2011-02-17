#!/usr/bin/perl
#  Read in .CSV files from Oscilloscopes and split them
#  into one settings file and one .CSV file containing
#  only numbers.


use strict;
use warnings;

my $dir;

if (@ARGV) {
	$dir = shift @ARGV;
	die "Directory doesn't exist: '$dir'\n" unless -e $dir;
}

my @files = <$dir/*>;

foreach my $file (@files) {
	next unless $file =~ /.*\.csv$/i;
	open(my $read, '<', $file) or (warn "Could not open '$file', skipping...\n" && next);
	open(my $writeNum, '>', $file . "_num") or (warn "Could not open '$file" . "_num' for writing. Skipping..." && next);
	open(my $writeSet, '>', $file . "_set") or (warn "Could not open '$file" . "_set' for writing. Skipping..." && next);
	while (<$read>) {
		chomp;
		my $line = $_;
		print "$line\n";
		my @cols = split(/,/, $line);
		print $writeNum "$cols[3],$cols[4]\n";
		if (length($cols[0]) > 0) {
			print $writeSet "$cols[0],$cols[1]\n";
		}
	}
	close($read);
	close($writeNum);
	close($writeSet);
}

