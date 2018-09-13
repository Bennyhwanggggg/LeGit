#!/usr/bin/perl -w

use File::Compare;
use File::Copy;
use File::Basename;

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
		mkdir $init_directory or die "legit.pl: error: Failed to create $init_directory - $!\n";
		mkdir $commits_directory or die "legit.pl: error: Failed to create $commits_directory - $!\n";
		mkdir $index_folder or die "legit.pl: error: failed to create $index_folder = $!\n";
		open my $INDEX_INIT, '>', $index_file or die "legit.pl: error: Failed to initalize $index_file\n";
		close $INDEX_INIT;
		open my $LOG_INIT, '>', $log_file or die "legit.pl: error: Failed to initalize $log_file\n";
		close $LOG_INIT;
		print "Initialized empty legit repository in $init_directory\n";
		exit 0;
	} else {
		print "legit.pl: error: $init_directory already exists\n";
		exit 1;
	}
}

# get the last commit number, -1 if no commit made
sub getCommitNumber{
	my $current_commit_number = -1;
	my @list_of_commit_dirs = glob($commits_directory . '/*');
	if (@list_of_commit_dirs) {
		$current_commit_number = @list_of_commit_dirs - 1;
	}
	return $current_commit_number;
}

# check if index is same as repo
sub checkIfIndexSameAsRepo {
	my ($current_commit_number) = @_;
	if ($current_commit_number < 0) { # when there is no previous commit
		return 0;
	}
	# if ($current_commit_number != 0) {
	my $latest_commit_folder = "$commits_directory/$current_commit_number";
	for $file (glob($index_folder . '/*')) {
		my $file_name = basename($file, "*");
		my $check_file_path = "$latest_commit_folder/$file_name";
		if ((!-e $check_file_path) or (compare($file, $check_file_path) != 0)) {
			return 0;
		} 
	}

	for $file (glob($latest_commit_folder . '/*')) {
		my $file_name = basename($file, "*");
		my $check_file_path = "$index_folder/$file_name";
		if ((!-e $check_file_path) or (compare($file, $check_file_path) != 0)) {
			return 0;
		} 
	}
	return 1;
}

sub commitChanges {
	my ($current_commit_number, $message) = @_;
	my $new_commit_folder = "$commits_directory/$current_commit_number";
	if (!-e $new_commit_folder) {
		mkdir $new_commit_folder or die "legit.pl: error: failed to create $new_commit_folder $!\n";
	}
	for $file (glob($index_folder . '/*')) {
		my $file_name = basename($file, "*");
		copy($file, "$new_commit_folder/$file_name") or die "legit.pl: error: failed to copy '$file' into '$new_commit_folder/$file'. - $!\n";
	}
	open my $LOG, '>>', $log_file or die "legit.pl: error: Failed to open $log_file\n";
	print $LOG "$current_commit_number $message\n";
	close $LOG;
	print "Committed as commit $current_commit_number\n";
}

sub updateIndex {
	my (@to_be_indexed_files) = @_;
	open my $INDEX_OUT, '>', $index_file or die "legit.pl: error: can not open $index_file: $!\n";
	for $to_be_indexed_file (@to_be_indexed_files) {
		if (-e $to_be_indexed_file) {
			open my $CURRENT_IN, '<', "$to_be_indexed_file" or die "legit.pl: error: can not open $to_be_indexed_file - $!\n";
			my $file_name = basename($to_be_indexed_file, "*");
			my $file = $to_be_indexed_file;
			print $INDEX_OUT "THIS IS A FILE LINE SEPARATOR<<<<<<=====$file=====>>>>>>THIS IS A FILE LINE SEPARATOR\n";
			while ($line = <$CURRENT_IN>) {
				print $INDEX_OUT $line;
			}
			close $CURRENT_IN;
		}
	}
	close $INDEX_OUT;
}

# make target_folder look the same as source_folder by copying everythin from one to another
sub updateIndexFolder {
	my (@files) = @_;
	foreach $file (@files) {
		my $file = basename($file, '*');
		my $index_file_path = "$index_folder/$file";
		if (!-e $file && -e $index_file_path) { # if file was removed
			unlink $index_file_path;
		} else {
			open my $CHECKER, '<', $file or die "legit.pl: error: can not open '$file'\n";
			close $CHECKER;
			copy($file, $index_file_path) or die "legit.pl: error: failed to copy '$file' into $index_file_path\n";
		}
	}
}

sub checkIfTwoFolderAreSame{
	my ($folder_1, $folder_2) = @_;

}
# Add should check if the added file is the same as the one that is commited
# if it is the same, don't do anything (don't add to index?)
# otherwise, 
# Index will contain list of files and their contents. But also use another folder and actually copy the file into there?
# so when a file is added, first check if it exist in that folder, if it is, replaced it, otherwise copy it into it and 
# scan through that folder while adding everythng in that folder into index's content
if ($ARGV[0] eq "add") {
	if (!-e $init_directory) {
		print "legit.pl: error: no $init_directory directory containing legit repository exists\n";
		exit 1;
	} else {
		shift @ARGV; # remove add from input
		if (!@ARGV) {
			print "legit.pl: error: internal error Nothing specified, nothing added.\n";
			exit 1;
		}

		# just check if it is in index_file_path and rewrite index at the end by scanning through the index_file_path
		updateIndexFolder(@ARGV);
		my @to_be_indexed_files = glob($index_folder . '/*' );
		updateIndex(@to_be_indexed_files);
		exit 0;
	}
}

# Commit command
# when commit compare the current index with current commit index
if ($ARGV[0] eq "commit") {
	shift @ARGV;
	if (!@ARGV) {
		print "usage: legit.pl commit [-a] -m commit-message\n";
		exit 1;
	}
	my $command = shift @ARGV;
	if ($command eq "-m") {
		my $message = shift @ARGV;
		if (@ARGV or !defined $message) {
			print "usage: legit.pl commit [-a] -m commit-message\n";
			exit 1;
		}
		my $current_commit_number = getCommitNumber();
		# if commits have been made so far
		if (-z $index_file or checkIfIndexSameAsRepo($current_commit_number) == 1){
			print "nothing to commit\n";
			exit 0;
		}
		$current_commit_number++;
		commitChanges($current_commit_number, $message);
		exit 0;
	} elsif ($command eq "-a" || $command eq "-am") {
		if ($command eq "-a" ) {
			$command2 = shift @ARGV; 
			if ($command2 ne "-m") {
				print "usage: legit.pl commit [-a] -m commit-message\n";
				exit 1;
			}
		}
		$message = shift @ARGV;
		if (@ARGV or !defined $message) {
			print "usage: legit.pl commit [-a] -m commit-message\n";
			exit 1;
		}
		# get all the files in the current index and update them
		# check if anything in index to commit
		if (-z $index_file) {
			print "nothing to commit\n";
			exit 0;
		}

		# update everything in index with whati

		# just check if it is in index_file_path and rewrite index at the end by scanning through the index_file_path
		# $all_same = 1;
		# foreach $file_in_current_index (glob($index_folder . "/*")) {
		# 	$file_name = basename($file_in_current_index, "*");
		# 	if (!-e $file_name){
		# 		$all_same = 0;
		# 		unlink $file_in_current_index;
		# 		next;
		# 	}
		# 	if (compare($file_name, $file_in_current_index) != 0){
		# 		$all_same = 0;
		# 	}
		# 	copy($file_name, $file_in_current_index) or die "$0: error: failed to copy $file_name into $file_in_current_index\n"; 
		# 	# if a file is deleted, it should be deleted from index as well 
		# }
		# if ($all_same == 1 and ! -z){
		# 	print "nothing to commit\n";
		# 	exit 0;
		# }

		my @to_be_indexed_files = glob($index_folder . '/*' );
		updateIndexFolder(@to_be_indexed_files);
		updateIndex(@to_be_indexed_files);
		my $current_commit_number = getCommitNumber();
		if (checkIfIndexSameAsRepo($current_commit_number) == 1){
			print "nothing to commit\n";
			exit 0;
		}
		$current_commit_number++;
		commitChanges($current_commit_number, $message);
		exit 0;
	}
}

# log command
if ($ARGV[0] eq "log") {
	if (-z $log_file) {
		print "legit.pl: error: your repository does not have any commits yet\n";
		exit 1;
	}
	if (!-e "$commits_directory/0") {
		print "legit.pl: error: your repository does not have any commits yet\n";
		exit 1;
	}
	my $command = shift @ARGV;
	if (@ARGV) {
		print "usage: $0 log\n";
		exit 1;
	}

	open $LOGREAD, '<', $log_file or die "legit.pl: error: failed to open $log_file\n";
	@lines = reverse <$LOGREAD>;
	foreach $line (@lines) {
		print $line;
	}
	exit 0;
}

# show command
if ($ARGV[0] eq "show") {
	shift @ARGV;
	if (@ARGV == 0) {
		print "usage: $0 <commit>:<filename>\n";
		exit 1;
	}
	$commit_filename = shift @ARGV;
	# if doesn't match input pattern, it is invalid object
	# if pattern match, split by : then check if valid commit
	if ($commit_filename !~ m/.*:.*/) {
		print "invalid object $commit_filename\n";
		exit 1;
	}
	@input = split /:/, $commit_filename;
	if (@input > 2){
		print "usage: legit.pl <commit>:<filename>\n";
		exit 1;
	}
	$commit_number = shift @input;
	$file = shift @input;
	# if only one input, it must be the file name and we go to index to show its content
	if ($commit_number eq ''){
		# check if any commit yet
		if (!-e "$commits_directory/0") {
			print "legit.pl: error: your repository does not have any commits yet\n";
			exit 1;
		}
		$retrieved_file = "$index_folder/$file";
		if (!-e $retrieved_file) {
			print "legit.pl: error: '$file' not found in index\n";
			exit 1;
		}
		open my $OUT, '<', $retrieved_file or die "legit.pl: error: failed to open $retrieved_file\n";
		while ($line = <$OUT>) {
			print $line;
		}
		exit 0;
	} elsif ($commit_number =~ m/\d/) {
		$retrieved_file_directory = "$commits_directory/$commit_number";
		# if the commit number doesn't exist
		if (!-e $retrieved_file_directory) {
			print "legit.pl: error: unknown commit '$commit_number'\n";
			exit 1;
		}
		$retrieved_file = "$retrieved_file_directory/$file";
		if (!-e $retrieved_file) {
			print "legit.pl: error: '$file' not found in commit $commit_number\n";
			exit 1;
		}
		open my $OUT, '<', $retrieved_file or die "legit.pl: error: failed to open $retrieved_file\n";
		while ($line = <$OUT>) {
			print $line;
		}
		exit 0;
	} else {
		print "legit.pl: error: unknown commit '$commit_number'\n";
		exit 1;
	}
}

# rm
if ($ARGV[0] eq "rm") {
	if (!-e "$commits_directory/0") {
		print "legit.pl: error: your repository does not have any commits yet\n";
		exit 1;
	}
	my $command = shift @ARGV;
	if ($ARGV[0] eq "--cached") {
		# only remove from index
		shift @ARGV;
		for $file (@ARGV) { # reference implementation checks everything first before deleting
			my $index_file_path = "$index_folder/$file"; 
			if (!-e $index_file_path){
				print "legit.pl: error: '$file' is not in the legit repository\n";
				exit 1;
			}
		}
		for $file (@ARGV) {
			my $index_file_path = "$index_folder/$file"; 
			unlink $index_file_path;
			my @to_be_indexed_files = glob($index_folder . '/*' );
			updateIndex(@to_be_indexed_files);
		}
		exit 0;
	} elsif ($ARGV[0] eq "--force") {
		shift @ARGV;
		# only check if it is in index?
		for $file (@ARGV) {
			my $index_file_path = "$index_folder/$file";
			if (!-e $index_file_path) {
				print "legit.pl: error: '$file' is not in the legit repository\n";
				exit 1;
			}
		}
		for $file (@ARGV) {
			if (-e $file) {
				unlink $file;
			}
			updateIndexFolder($file);
		}
		my @to_be_indexed_files = glob($index_folder . '/*' );
		updateIndex(@to_be_indexed_files);
		exit 0;
	} else {
		my $current_commit_number = getCommitNumber();
		# if not in repo or index = not in legit repo
		# if in index but not repo or different from repo (file was modifed and added) =  has changes staged in the index
		# if file is differnet from index (and repo) differnt to working file (changes made in directory  but no add)
		for $file (@ARGV) {
			my $commited_file = "$commits_directory/$current_commit_number/$file";
			my $index_file_path = "$index_folder/$file";
			if (!-e $commited_file and !-e $index_file_path) {
				print "legit.pl: error: '$file' is not in the legit repository\n";
				exit 1;
			}
			if (-e $index_file_path) { 
				if (compare($file, $index_file_path) != 0 and compare($index_file_path, $commited_file) != 0){
					print "legit.pl: error: '$file' in index is different to both working file and repository\n";
					exit 1;
				}
				if (compare($file, $index_file_path) != 0) {
					print "legit.pl: error: '$file' in repository is different to working file\n";
					exit 1;
				}
				if (!-e $commited_file or compare($commited_file, $index_file_path) != 0) {
					print "legit.pl: error: '$file' has changes staged in the index\n";
					exit 1;
				}
			}
		}
		for $file (@ARGV) {
			if (-e $file) {
				unlink $file;
			}
			updateIndexFolder($file);
		}
		my @to_be_indexed_files = glob($index_folder . '/*' );
		updateIndex(@to_be_indexed_files);
		exit 0;
	}
}

# # status
# if ($ARGV[0] eq "status") {
# 	my $current_commit_number = -1;
# 	my @list_of_commit_dirs = glob($commits_directory . '/*');
# 	if (@list_of_commit_dirs) {
# 		$current_commit_number = @list_of_commit_dirs - 1;
# 	} else {
# 		print "$0: error: your repository does not have any commits yet\n";
# 		exit 1;
# 	}
# 	print "$current_commit_number\n";
# 	# compare the files in current directory with the one in commit
# 	# a - file modified and changes in index.  --- current, index, repo are different. File was commited, then changed which was added then changed again wich was not added
# 	# b - file modified												 --- index and repo are different. File was commited, then changed, which was added, but not commited
# 	# c - changes in index 										--- file was commited, then modified but modification is not added
# 	# d - file deleted												--- file was removed with rm, changes not added to index or commited
# 	# e - deleted														--- file remove using legit rm, removed from index and current directory (does not rm from repo yet? so use this to show up on status)
# 	# f - same as repo. 									-- commited and no changes made. repo, index, current are same
# 	# g - added to index.  										--- first time added to index? not present in repo
# 	# h - untracked

# 	# rm => cannot work when repo is different from what is in current (file was commited before then modified. new modification not added) (err: in repository is different to working file)
# 	# => cannot work when index and repo are different (err: has changes staged in the index)
# 	foreach $file (glob("*")){
# 		$path_in_repo = "$commits_directory/$current_commit_number/$file";
# 		if (-e $path_in_repo) {
# 			if (compare($file, $path_in_repo) == 0){
# 				$status{$file} = 'same as repo';
# 			}
# 		} else {
# 			$status{$file} = 'untracked';
# 		}
# 	}

# }
