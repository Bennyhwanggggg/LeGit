#!/bin/sh

# check subset0 and subset1 combined. See if rm are having the right effects


legit.pl init
seq 1 10 > file1
echo abcdefg > file2
echo line1 > file3
echo line2 >> file3
legit.pl add file1 file2
legit.pl commit -m 'commit 1'
rm file2
perl -pi -e 's/1/114/' file1
legit.pl commit -a -m 'commit 2'
legit.pl status
legit.pl show 2:file2
legit.pl show 1:file2
legit.pl show :file3
legit.pl show 1:file1
legit.pl show 2:file1
legit.pl show 0:file1
perl -pi -e 's/0/55/' file1
legit.pl show :file1
legit.pl status
legit.pl commit -a -m commit-3
legit.tpl add file3
legit.pl status
legit.pl rm --force --cached file3
legit.pl log
legit.pl rm --cached --force file1
legit.pl status
legit.pl commit -m commit-4
legit.pl log
legit.pl status
echo new >> file4
echo new2 >> file5
legit.pl status
legit.pl add file4
legit.pl add file5
legit.pl commit -m commit-5
legit.pl status
legit.pl log
legit.pl rm file4
echo newline >> file5
legit.pl add file5
legit.pl rm file5
