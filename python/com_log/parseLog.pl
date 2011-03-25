#/!usr/bin/perl
# Read in a raw log file from the Storque and output .csv files
# with data corresponding to all of the different communication tags (PID, IMU, etc)
# These .csv files will be located in parsedLogs/<Date>/<com_tag>.csv


use strict;
use warnings;
use Switch;

use Data::Dumper;

my @files;

# Parse the options and arguments.
#   This is weak right now.  
#    Options must be first in the form of: -<option><? option Argument>
#    where <option> is one character and <option Argument> follows <option>
#    with no space.
#      Current Options are:
#        -d<?directory> : Parse all files in a specified directory
#          If no directory is supplied, the current directory is used.
#		 -r : Parse most recent log file (Looks at files that begin with 'Log')
#        -m : Prints the directory containing .csv files of the last parsed log
#             (for matlab system call use)
#		 -v : Verbose.  Can't be used in conjunction with -m
#    Arguments follow options.  
#      Current Arguments are:
#        1) file to parse

my $printLastCsvDir = 0;   # Turned true by the -m option
my $lastCsvDir = '';
my $verbose = 0;
my $delimeter = '_';  # Delimeter between fields (this changed from space to 
					  # underscore at some point)
					
my $logDir = 'parsedLogs';
my $moreOptionsAllowed = 1;

for my $arg (@ARGV) {
		if (($arg =~ m/^\-(\w)(\w*)/i) && ($moreOptionsAllowed)) {
		my $option = $1;
		my $optionArg = $2;
		switch($option) {
			case 'd' {
				if ($optionArg) {
					unless (-d $optionArg) {
						die "$0: In -d option: $optionArg directory does not exist.\n";
					}
					$optionArg = ($optionArg . '/') unless $optionArg =~ m/\/$/;
				} else {
					$optionArg = './';
				}
				opendir(my $requestedDir, "$optionArg") or die "Could not open directory '$optionArg'\n";

				push @files, grep(/Log_\d/,readdir($requestedDir));
			}
			case 'r' {
				my @filesHere;
				my $newestFile = '';
				opendir(my $curDir,'.') or die "Could not open directory '.'\n";
				@filesHere = readdir($curDir);
				for my $file (@filesHere) {
					next unless $file =~ m/Log_\d/i;  # Weakly match only log files
					if ($newestFile eq '') {
						$newestFile = $file;
						next;
					}
					my $modifiedTime = (stat($file))[9];  # in seconds
					if ($modifiedTime > (stat($newestFile))[9]) {
						$newestFile = $file
					}
				}
				push @files, $newestFile;
			}
			case 'm' {
				$verbose = 0;
				$printLastCsvDir = 1;
			}
			case 'v' {
				$verbose = 1;
			}
		}
	} else {
		$moreOptionsAllowed = 0;
		push @files, $arg;
	}
}

FILES:
for my $file (@files) {
	die "$0: '$file' does not exist!\n" unless -e $file;

	open(my $logFh, '<', "$file") or die "$0: Cannot open '$file' for reading.\n";

	my %data;  # Keys will be <com_tag>s, and each value will be a 2 dimensional
		       # anonymous array where row 0 will hold column entries corresponding
		       # to the data in the first <com_tag> message sent.

	# Right now, we can only deal with '_' delimenters, so throw an error if
	# the user wants to use spaces instead.
	die "$0: '$delimeter' not yet supported.\n" unless $delimeter eq '_';

	print "Processing '$file'...\n" if $verbose;
	print "\tReading..." if $verbose;
	
	while (my $line = <$logFh>) {
		# Make sure this log file is formatted as we expect.
		unless ($line =~ m/.*$delimeter.*/){
			next;
		}
		
		chomp $line;
	
		next unless $line =~ m/^IN/;  # Skip output log lines
	
		$line =~ s/^IN:\s*//i;  # Strip leading IN: and whitespace
	
		 # Fix the RCI Tag.  It is formatted _R_C_I in the raw logs.
		$line =~ s/$delimeter\s*R$delimeter\s*C\s*$delimeter\s*I/RCI/;
	
		# Not sure what $flag is.  It's universally 'd' for every line of data sent,
		# but it's definitely not data
		my ($comTag, $dataTag, $length, @data) = split($delimeter, $line);
	
		if ($comTag eq 'RCI') {
			# RCI doesn't have a length, so this $length is actually good data
			unshift @data, $length;
			unshift @data, $dataTag;
		}
	
		#print "$comTag: \n\t";
		#print join(' ', @data);
		#print "\n";
		# Add a row of data to this <com_Tag>'s array of data.
		push @{$data{$comTag}}, \@data;
	}
	print "Done!\n" if $verbose;
	print "\tWriting..." if $verbose;
	
	unless (-d "$logDir/$file") {
		unless (-d $logDir) {
			mkdir $logDir or die "$0: Could not make '$logDir' directory for logging.\n";
		}
		mkdir "$logDir/$file" or die "$0: Could not make '$logDir/$file' directory for logging.\n";
	}

	for my $comTag (keys %data) {
		my $comLogFile = "$logDir/$file/$comTag" . '.csv';
		open (my $comFh, '>', $comLogFile) or (warn "$0: Cannot open '$comLogFile' for logging.\n" && (next FILES) && ($verbose && print("\n")));
	
		for my $dataRow (@{$data{$comTag}}) {
			for my $dataPiece (@{$dataRow}) {
				$dataPiece =~ s/\r//g;
				print $comFh "$dataPiece, ";
			}
			print $comFh "\n";
		}
	}
	print "Done!\n" if $verbose;
	
	$lastCsvDir = "$logDir/$file/";
}

# Return directory containing .csv files for last parsed log.
if ($printLastCsvDir == 1) {
	print "$lastCsvDir\n";
}