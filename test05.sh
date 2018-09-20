#!/bin/sh

# test 5 checks add, commit, rm --cache, commit -a -m, commit, log, add, commit, rm -forced
# aim to check if rm --cache and forced are affecting the ability to commit properly

legit.pl init 
echo 123456 > file1
echo abcdefg > file2
echo line1 > file3
legit.pl add file1 file2 file3 
legit.pl commit -m 'commit 1' 
legit.pl rm --cached file2 
legit.pl status 
legit.pl commit -a -m commit2 
legit.pl status 
legit.pl commit -m commit3 
legit.pl log 
legit.pl rm --cached file1 file3 
legit.pl commit -a -m commit4 
legit.pl rm --cached file1 


