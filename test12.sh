#!/bin/sh

# check subset0 and subset2 combined


legit.pl init
seq 1 10 > file1
echo abcdefg > file2
echo line1 > file3
echo line2 >> file3
legit.pl add file1 file2 file3
legit.pl commit -m 'commit 1'
seq 10 100 >> file4
legit.pl branch b1
legit.pl checkout b1
legit.pl add file4
legit.pl rm file1
legit.pl commit -a -m 'commit 2'
legit.pl rm file1
legit.pl status
legit.pl add file3
echo line4 >> file3
echo line5 >> file4
legit.pl commit -a -m 'commit 3'
legit.pl log
legit.pl show :file3
legit.pl show :file4
legit.pl show :file2
legit.pl show :file1
legit.pl show 0:file1
legit.pl show 1:file1
echo line6 >> file3
legit.pl commit -m 'commit 4'
legit.pl status
legit.pl log
legit.pl checkout master
legit.pl merge b1 -m merge-b1
legit.pl status
legit.pl log