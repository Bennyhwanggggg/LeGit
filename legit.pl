#!/usr/bin/perl -w

if (!@ARGV) {
	print "Usage: $0 <comand>\n";
}

$init_directory = ".legit";
$index_file = "$init_directory/index";
$log_file = "$init_directory/log";

if (@ARGV == 1 and $ARGV[0] eq "init") {
	if (!-e $init_directory) {
		mkdir $init_directory or die "$0: error: Failed to create $init_directory - $!\n";
		open my $INDEX_INIT, '>', $index_file or die "$0: error: Failed to initalize $index_file\n";
		close $INDEX_INIT;
		open my $LOG_INIT, '>', $log_file or die "$0: error: Failed to initalize $log_file\n";
		close $LOG_INIT;
		print "Initialized empty legit repository in $init_directory\n";
		exit 0;
	} else {
		print "$0: error: $init_directory already exists\n";
		exit 1;
	}
}

if ($ARGV[0] eq "add") {
	if (!-e $init_directory) {
		print "$0: error: no $init_directory directory containing legit repository exists\n";
	} else {
		shift @ARGV;
		if (!@ARGV) {
			print "$0: error: internal error Nothing specified, nothing added.\n";
			exit 1;
		}
		open my $index_file, '>>', $index_file or die "$0: error: Cannot open $index_file: $!\n";
		foreach $file (@ARGV) {
			open my $current_file, '<', $file or die "$0: error: Cannot open $file\n";
			print $index_file "$file\n";
		}
		close $index_file
	}
}

if ($ARGV[0] eq "commit") {
	shift @ARGV;
	if (!@ARGV) {
		print "usage: $0 commit [-a] -m commit-message\n";
		exit 1;
	}
	$command = shift @ARGV;
	if ($command eq "-m") {
		$message = shift @ARGV;
		if (@ARGV) {
			print "usage: $0 commit [-a] -m commit-message\n";
			exit 1;
		}
		# check if anything in index to commit
		if (-z $index_file) {
			print "nothing to commit\n";
			exit 0;
		}
		# get current commit number, use logs?
		# $n = 0?
		print "$message\n"
	}
}