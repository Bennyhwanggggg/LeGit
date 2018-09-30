#!/bin/sh

# check subset0 and subset1 combined. Check rm on changed files


legit.pl init
seq 1 10 > file1
echo abcdefg > file2
echo line1 > file3
echo line2 >> file3
legit.pl add file1 file2
legit.pl commit -m 'commit 1'
rm file3
perl -pi -e 's/1/114/' file1
legit.pl commit -a -m 'commit 2'
legit.pl rm file1
legit.pl status
legit.pl add file3
echo line4 >> file3
echo line5 >> file4
legit.pl commit -m 'commit 3'
legit.pl log
legit.pl add file4
echo line6 >> file3
legit.pl commit -m 'commit 4'
legit.pl status
legit.pl log
echo line7 >> file3
legit.pl rm file3
legit.pl rm --force file3
echo line8 >> file4
legit.pl rm --cached file4
legit.pl status