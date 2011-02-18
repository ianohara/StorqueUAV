#!/usr/bin/perl
#  Read in .CSV files from Oscilloscopes and split them
#  into one settings file and one .CSV file containing
#  only numbers.


use strict;
use warnings;
use Switch;

use Scalar::Util qw(looks_like_number);

my $dir;
my $verbose = 0;


if (@ARGV) {
	$dir = shift @ARGV;
	die "Directory doesn't exist: '$dir'\n" unless -e $dir;
	while (my $opt = shift @ARGV) {
		next unless $opt =~ m/^-(\w)/;
		switch ($1) {
			case 'v'     { $verbose = 1 }
			else { print "Invalid Option '-$1'.\n" }
		}
	}
}

my @files = <$dir*>;

if (@files == 0) {
	die "No files found in '$dir'\n";
}

foreach my $file (@files) {
	next unless $file =~ /.*\.CSV$/;
	
	open(my $read, '<', $file) or (warn "Could not open '$file', skipping...\n" && next);

	my $numFile = $dir . "Numerical.csv";
	my $setFile = $dir . "Settings.conf";
	my $setNumFile = $dir . "Settings.csv";
	
	open(my $writeNum, '>', $numFile) or (warn "Could not open '$numFile' for writing. Skipping...\n" && next);
	open(my $writeSet, '>', $setFile) or (warn "Could not open '$setFile' for writing. Skipping...\n" && next);
	open(my $writeNumSet, '>',$setNumFile) or (warn "Could not open '$setNumFile for writing.  Skipping...\n" && next);

	my $count = 0;
	print "Reading from File: $file ..." if $verbose;;
	while (my $file = <$read>) {
		my @lines = split(/\r/,$file);
		foreach my $line (@lines) {
			$count++;
			my @cols = split(/,/, $line);	
			print $writeNum "$cols[3],$cols[4]\n";
			if (length($cols[0]) > 0) {
				print $writeSet "$cols[0]=$cols[1]\n";
				if (looks_like_number($cols[1])) {
					print $writeNumSet "$cols[1]\n";
				}
				else {
					print $writeNumSet "-1\n"
				}
			}
		}
	}
	print "Done!  Read $count lines.\n" if $verbose;
	
	close($read);
	close($writeNum);
	close($writeSet);
}



