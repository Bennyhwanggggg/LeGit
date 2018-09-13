#!/usr/bin/perl -w

use File::Compare;
use File::Copy;
use File::Basename;
use File::Path;

if (!@ARGV) {
	print "Usage: $0 <comand>\n";
}

# $index_master_file = "$init_directory/index";

$init_directory = ".legit";
$commits_directory = "$init_directory/commits";
$index_file = "$init_directory/index";
$log_file = "$init_directory/log";
$index_folder = "$init_directory/index_files";
$branch_folder = "$init_directory/branches";
$branch_track = "$init_directory/currentBranch";

$commits_master_directory = "$init_directory/commits";
$index_master_folder = "$init_directory/index_files";
# $log_master_file = "$init_directory/log";

if (@ARGV == 1 and $ARGV[0] eq "init") {
	if (!-e $init_directory) {
		mkdir $init_directory or die "legit.pl: error: Failed to create $init_directory - $!\n";
		mkdir $commits_directory or die "legit.pl: error: Failed to create $commits_directory - $!\n";
		mkdir $index_folder or die "legit.pl: error: failed to create $index_folder = $!\n";
		mkdir $branch_folder or die "legit.pl: error: failed to create $branch_folder\n";
		open my $INDEX_INIT, '>', $index_file or die "legit.pl: error: Failed to initalize $index_file\n";
		close $INDEX_INIT;
		open my $LOG_INIT, '>', $log_file or die "legit.pl: error: Failed to initalize $log_file\n";
		close $LOG_INIT;
		open my $BRANCH_INIT, '>', $branch_track or die "legit.pl: error: Failed to initalize $branch_track\n";
		close $BRANCH_INIT;
		print "Initialized empty legit repository in $init_directory\n";
		exit 0;
	} else {
		print "legit.pl: error: $init_directory already exists\n";
		exit 1;
	}
}

if (! -z $branch_track) {
	open my $BRANCHGET, '<', $branch_track or die "legit.pl: error: failed to read $branch_track\n";
	$CURRENT_BRANCH = <$BRANCHGET>;
	close $BRANCHGET;
	print "$CURRENT_BRANCH\n";
	$commits_directory = "$branch_folder/$CURRENT_BRANCH/commits";
	$index_file = "$branch_folder/$CURRENT_BRANCH/index";
	$log_file = "$branch_folder/$CURRENT_BRANCH/log";
	$index_folder = "$branch_folder/$CURRENT_BRANCH/index_files";
} else {
	print "On master right now\n";
}

# get the last commit number, -1 if no commit made
sub getCommitNumber{
	my $current_commit_number = -1;
	my @list_of_commit_dirs = glob($commits_directory . '/*');
	if (@list_of_commit_dirs == 0){
		return -1;
	}
	@list_of_commit_dirs = sort @list_of_commit_dirs;
	return basename($list_of_commit_dirs[$#list_of_commit_dirs]);
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

sub copyAllFiles {
	my ($source_folder, $dest_folder) = @_;
	mkdir $dest_folder if !-e $dest_folder;
	for $file (glob($source_folder . "/*")){
		if (-d $file){
			# return copyAllFiles($file, $dest_folder);
			next;
		}
		my $file_name = basename($file);
		my $dest_file = "$dest_folder/$file_name";
		copy($file, $dest_file);
	}
}

sub checkIfTwoFoldersAreTheSame {
	my ($folder_1, $folder_2) = @_;
	for $file (glob($folder_1 . '/*')) {
		my $file_name = basename($file, "*");
		my $check_file_path = "$folder_2/$file_name";
		if ((!-e $check_file_path) or (compare($file, $check_file_path) != 0)) {
			return 0;
		} 
	}
	for $file (glob($folder_2 . '/*')) {
		my $file_name = basename($file, "*");
		my $check_file_path = "$folder_1/$file_name";
		if ((!-e $check_file_path) or (compare($file, $check_file_path) != 0)) {
			return 0;
		} 
	}
	return 1;
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
	my $current_commit_number = getCommitNumber();
	my $command = shift @ARGV;
	if ($ARGV[0] eq "--cached") {
		# only remove from index
		shift @ARGV;
		for $file (@ARGV) { # reference implementation checks everything first before deleting
			my $index_file_path = "$index_folder/$file"; 
			my $commited_file = "$commits_directory/$current_commit_number/$file";
			if (!-e $index_file_path){
				print "legit.pl: error: '$file' is not in the legit repository\n";
				exit 1;
			}
			if (-e $commited_file and compare($commited_file, $index_file_path) != 0 and compare($index_file_path, $file) != 0) {
				print "legit.pl: error: '$file' in index is different to both working file and repository\n";
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

# legit rm = not in index or current ==> deleted
# rm = not in current but in index ==> file deleted
# if not in all three ==> gone
# if in current and not index ==> untracked
# in index but not in commit ==> added to index
if ($ARGV[0] eq "status") {
	if (!-e "$commits_directory/0") {
		print "legit.pl: error: your repository does not have any commits yet\n";
		exit 1;
	}
	my $current_commit_number = getCommitNumber();
	# get all the files in everywhere
	my @current_files = glob("*");
	my @index_files = glob($index_folder . "/*");
	my @commited_files = glob("$commits_directory/$current_commit_number" . "/*");
	for $file (@current_files) {
		if (-d $file ){
			next;
		}
		$all_files{basename($file)}++;
	}
	for $file (@index_files) {
		if (-d $file ){
			next;
		}
		$all_files{basename($file)}++;
	}
	for $file (@commited_files) {
		if (-d $file ){
			next;
		}
		$all_files{basename($file)}++;
	}
	for $file (keys %all_files) {
		$committed_file = "$commits_directory/$current_commit_number/$file";
		$indexed_file = "$index_folder/$file";
		# if exist in all three, check if all same or which ones are different
		if (-e $file and -e $committed_file and -e $indexed_file) {
			# if all three are same then same as repo
			if (compare($file, $committed_file) == 0 and compare($file, $indexed_file) == 0) {
				$all_files{$file} = "same as repo";
			# modified and changed in index if current != index and index != commited
			} elsif (compare($file, $indexed_file) != 0 and compare($indexed_file, $committed_file)) {
				$all_files{$file} = "file modified and changes in index";
			} elsif (compare($committed_file, $indexed_file) != 0) {
				$all_files{$file} = "file modified";
			} elsif (compare($file, $indexed_file) != 0){
				$all_files{$file} = "changes in index";
			}
		# handle delete cases, if only not in current => file deleted, not in both index and current => deleted
		} elsif (! -e $file and ! -e $indexed_file and -e $committed_file) {
			$all_files{$file} = "deleted";
		} elsif (! -e $file and -e $indexed_file) {
			$all_files{$file} = "file deleted";
		} elsif (-e $file and ! -e $indexed_file) {
			$all_files{$file} = "untracked";
		} elsif (-e $indexed_file and !-e $committed_file) {
			# added to index only if it doesn;t exist in commit
			$all_files{$file} = "added to index";
		}
	}
	foreach my $file (sort keys %all_files){
		print "$file - $all_files{$file}\n";
	}
	exit 0;
}

if ($ARGV[0] eq "branch") {
	if (!-e "$commits_directory/0") {
		print "legit.pl: error: your repository does not have any commits yet\n";
		exit 1;
	}
	my $command = shift @ARGV;
	if (@ARGV == 0) {
		my @branches = glob("$branch_folder" . "/*");
		for $branch (@branches) {
			if (-d $branch) {
				$branch = basename($branch);
				print "$branch\n";
			}
		}
		print "master\n";
		exit 0;
	} elsif ($ARGV[0] eq "-d") {
		shift @ARGV;
		if (@ARGV != 1) {
			print "usage: legit.pl [-d] <branch>\n";
			exit 1;
		}
		$branch_to_delete = shift @ARGV;
		if ($branch_to_delete eq "master") {
			print "legit.pl: error: can not delete branch 'master'\n";
			exit 1;
		}
		$branch_folder_to_del = "$branch_folder/$branch_to_delete";
		if (! -e "$branch_folder_to_del") {
			print "legit.pl: error: branch '$branch_to_delete' does not exist\n";
			exit 1;
		}
		# unmerged if repo to delete is different from master?
		$branch_to_delete_index = "$branch_folder_to_del/index_files";
		if (checkIfTwoFoldersAreTheSame($index_master_folder, $branch_to_delete_index) == 0) {
			print "legit.pl: error: branch '$branch_to_delete' has unmerged changes\n";
			exit 1;
		}
		rmtree $branch_folder_to_del;
		print "Deleted branch '$branch_to_delete'\n";
		exit 0;
	} else {
		my $new_branch_name = shift @ARGV;
		if (@ARGV) {
			print "usage: legit.pl [-d] <branch>\n";
			exit 1;
		}
		$new_branch = "$branch_folder/$new_branch_name";
		if (-e $new_branch or $new_branch_name eq "master") {
			print "legit.pl: error: branch '$new_branch_name' already exists\n";
			exit 1;
		}
		mkdir $new_branch or die "legit.pl: error: faile to create $new_branch\n";
		my $new_branch_index_folder = "$new_branch/index_files";
		my $new_branch_commit_folder = "$new_branch/commits";
		mkdir $new_branch_commit_folder if ! -e $new_branch_commit_folder;
		copy($index_file, "$new_branch/index");
		copy($log_file, "$new_branch/log");
		copyAllFiles($index_folder, $new_branch_index_folder);
		# copy commit history
		for $folder (glob($commits_directory . "/*")) {
			my $folder_name = $folder;
			$folder_name =~ s/.*\///;
			copyAllFiles($folder, "$new_branch_commit_folder/$folder_name");
		}
		exit 0;
	}
	exit 0;
}

if ($ARGV[0] eq "checkout") {
	if (!-e "$commits_master_directory/0") {
		print "legit.pl: error: your repository does not have any commits yet\n";
		exit 1;
	}
	shift @ARGV;
	if (@ARGV != 1) {
		print "usage: legit.pl checkout <branch-name>\n";
		exit 1;
	}
	$target_branch = $ARGV[0];
	# Update current branch marker
	open $BRANCHCHECK, '<', $branch_track;
	my $current_branch = <$BRANCHCHECK>;
	close $BRANCHCHECK;
	if (! defined($current_branch)) {
		$current_branch = "master";
	}
	if ($current_branch eq $target_branch) {
		print "Already on '$target_branch'\n";
		exit 1;
	}

	# if master, don't use branch folder
	if ($target_branch eq "master") {
		# store away the current branch. check if what is commited in current branch's latest commit is same as index
	}




	open $BRANCHUPDATE, '>', $branch_track;
	print $BRANCHUPDATE "$target_branch" if $target_branch ne "master";
	close $BRANCHUPDATE;

	# only put files in master folder if checking out from master
	print "Switched to branch '$target_branch'\n";
	exit 0;
}
