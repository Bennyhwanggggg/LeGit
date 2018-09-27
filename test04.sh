#!/bin/sh

# CHeck if rm -- forced combined with rm --cached are resulting in the right status and show is working with it

legit.pl init
echo 123456 > file1
echo abcdefg > file2
echo line1 > file3
legit.pl add file1 file2 file3
legit.pl commit -m 'commit 1'
legit.pl rm --force file2
legit.pl status
legit.pl log
legit.pl show 0:file2
legit.pl show :file2
legit.pl show :file1
echo another >> file1
legit.pl status
legit.pl rm --cached file3
legit.pl rm --cached file1 file2
legit.pl rm --cached file1
legit.pl status
legit.pl commit -m 'commit 2'
legit.pl show 1:file2
legit.pl show :file2
legit.pl show :file1
legit.pl show 0:file1
rm file1
legit.pl commit -a -m 'commit 3'
legit.pl log
legit.pl show :file1
legit.pl status

