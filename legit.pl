#!/usr/bin/perl -w

if (!@ARGV) {
	print "Usage: $0 <comand>\n";
}

if (@ARGV == 1 and $ARGV[0] eq "init") {
	$init_directory = ".legit";
	if (!-e $init_directory) {
		mkdir $init_directory or die "$0: error: Failed to create $init_directory - $!\n";
		print "Initialized empty legit repository in $init_directory\n";
	} else {
		print "$0: error: $init_directory already exists\n"
	}
}
