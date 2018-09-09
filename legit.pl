#!/usr/bin/perl -w

use File::Compare;
use File::Copy;
use File::BaseName;

if (!@ARGV) {
	print "Usage: $0 <comand>\n";
}

$init_directory = ".legit";
$commits_directory = "$init_directory/commits";
$index_file = "$init_directory/index";
$log_file = "$init_directory/log";
$index_folder = "$init_directory/index_files";

if (@ARGV == 1 and $ARGV[0] eq "init") {
	if (!-e $init_directory) {
		mkdir $init_directory or die "$0: error: Failed to create $init_directory - $!\n";
		mkdir $commits_directory or die "$0: error: Failed to create $commits_directory - $!\n";
		mkdir $index_folder or die "$0L error: failed to create $index_folder = $!\n";
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

# Add should check if the added file is the same as the one that is commited
# if it is the same, don't do anything (don't add to index?)
# otherwise, 
# Index will contain list of files and their contents. But also use another folder and actually copy the file into there?
# so when a file is added, first check if it exist in that folder, if it is, replaced it, otherwise copy it into it and 
# scan through that folder while adding everythng in that folder into index's content
if ($ARGV[0] eq "add") {
	if (!-e $init_directory) {
		print "$0: error: no $init_directory directory containing legit repository exists\n";
		exit 1;
	} else {
		shift @ARGV; # remove add from input
		if (!@ARGV) {
			print "$0: error: internal error Nothing specified, nothing added.\n";
			exit 1;
		}

		# just check if it is in index_file_path and rewrite index at the end by scanning through the index_file_path
		foreach $file (@ARGV) {
			open $CHECKER, '<', $file or die "$0: error: cannot open $file\n";
			close $CHECKER;
			# check if it already exist
			$index_file_path = "$index_folder/$file";
			if (!-e $index_file_path) {
				copy($file, $index_file_path) or die "$0: error: failed to copy $file into $index_file_path\n";
				print "$file didnt exist in $index_file_path, so it is now copied into it\n";
			} elsif (compare($file, $index_file_path) != 0) { # != 0 means are different
				copy($file, $index_file_path) or die "$0: error: failed to copy $file into $index_file_path - $!\n";
				print "$file existed in $index_file_path, but changes were detected so it is now updated\n";
			} else {
				print "$file existed in $index_file_path and no content change so no update made\n";
			}
		}
		open my $INDEX_OUT, '>', $index_file or die "$0: error: Cannot open $index_file: $!\n";
		my @to_be_indexed_files = glob($index_folder . '/*' );
		for $to_be_indexed_file (@to_be_indexed_files) {
			open my $CURRENT_IN, '<', "$to_be_indexed_file" or die "$0: error: Cannot open $to_be_indexed_file - $!\n";
			$file = $to_be_indexed_file;
			$file =~ s/.*\///;
			print $INDEX_OUT "THIS IS A FILE LINE SEPARATOR<<<<<<=====$file=====>>>>>>THIS IS A FILE LINE SEPARATOR\n";
			while ($line = <$CURRENT_IN>) {
				print $INDEX_OUT $line;
			}
			close $CURRENT_IN;
		}
		close $INDEX_OUT;
		exit 0;
	}
}

# when commit compare the current index with current commit index
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
		# check index against current commit index
		my $current_commit_number = -1;
		my @list_of_commit_dirs = glob($commits_directory . '/*');
		if (@list_of_commit_dirs) {
			$current_commit_number = @list_of_commit_dirs - 1;
		}
		$current_commit_number++;
		print $current_commit_number, "\n";
		# if commits have been made so far
		if ($current_commit_number != 0) {
			$latest_commit_folder = $list_of_commit_dirs[$#list_of_commit_dirs];
			$all_same = 1;
			for $file (glob($index_folder . '/*')) {
				$file_name = $file;
				$file_name =~ s/.*\///;
				$check_file_path = "$latest_commit_folder/$file_name";
				if (!-e $check_file_path){
					$all_same = 0;
					last;
				} elsif (compare($file, $check_file_path) != 0){
					$all_same = 0;
					last;
				}
			}
			if ($all_same == 1) {
				print "nothing to commit\n";
				exit 0;
			}
		}

		$new_commit_folder = "$commits_directory/$current_commit_number";
		if (!-e $new_commit_folder) {
			mkdir $new_commit_folder or die "$0: error: failed to create $new_commit_folder $!\n";
		}
		for $file (glob($index_folder . '/*')) {
			$file_name = $file;
			$file_name =~ s/.*\///;
			copy($file, "$new_commit_folder/$file_name") or die "$0: error: failed to copy $file into $new_commit_folder/$file. - $!\n";
		}

		open my $LOG, '>>', $log_file or die "$0: error: Failed to open $log_file\n";
		print $LOG "$current_commit_number $message\n";
		close $LOG;
		print "Commited as commit $current_commit_number\n";
		exit 0;
	}
}

if ($ARGV[0] eq "log") {
	if (-z $log_file) {
		print "$0: error: your repository does not have any commits yet\n";
		exit 1;
	}
	$command = shift @ARGV;
	if (@ARGV) {
		print "usage: $0 log\n";
		exit 1;
	}

	open $LOGREAD, '<', $log_file or die "$0: error: failed to open $log_file\n";
	@lines = reverse <$LOGREAD>;
	foreach $line (@lines) {
		print $line;
	}
	exit 0;
}