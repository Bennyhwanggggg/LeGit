#!/bin/sh

# aim to check if all error message are properly done and add, commit, log


legit.pl init 
legit.pl commit 
legit.pl log 
legit.pl show 
legit.pl show :a 
legit.pl commit -a -m test 
legit.pl rm 
legit.pl rm --force 
legit.pl rm --cached 
legit.pl rm --cached --force
legit.pl rm --force --force
legit.pl status 
legit.pl branch 
legit.pl commit -m test 
legit.pl branch -d test 
legit.pl merge 
echo "12345" > file
cat file 
legit.pl add file 
echo "abcde" >> file
cat file 
legit.pl commit -m commit1 
echo "another line" >> file
legit.pl commit -m commit2 
legit.pl commit -a -m commit3 
legit.pl log
echo "newfile created" > file2
echo "another file" > file3
legit.pl commit -a -m commit4
legit.pl add file2
echo "6" >> file
legit.pl commit -m commit5
legit.pl commit -a -m commit 6
legit.pl log
