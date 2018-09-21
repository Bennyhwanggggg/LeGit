#!/bin/sh

# test 1 checks add, commit, log, add, log, commit, log, show, failed commit, log
# aim to test if commit, log and show are working propely


legit.pl init
seq 1 10 > file1
legit.pl add file1
cat file1
legit.pl log
legit.pl commit -m commit 1
legit.pl commit -m commit-1
legit.pl log
echo line1 > test_file_2
echo new line >> file1
legit.pl add file1
legit.pl log 
legit.pl commit -m commit-2
legit.pl log 
legit.pl show 4:file1
legit.pl show 4:unknown
legit.pl show 0:unknown
legit.pl show 0:file1
legit.pl show 1:file1
legit.pl commit -m commit-3
legit.pl log 
legit.pl status
legit.pl add test_file_2
echo 111 >> file1
legit.pl status
legit.pl commit -a -m  commit-4
legit.pl log
legit.pl status
legit.pl show 2:test_file_2
legit.pl show :test_file_2
legit.pl show :file1














