#!/bin/sh

# test 3 checks add, commit, rm --forced, status, log, add, commit, status, rm -- cached, status, legit rm

test_folder="test3"
if test -e $test_folder
then
	rm -r $test_folder
fi

mkdir $test_folder
cp "legit.pl" "$test_folder/legit.pl"

cd $test_folder

test_file_1="file1"
test_file_2="file2"
test_file_3="file3"

# The expected result are retrived from reference implementation using the same commands
expected="expected.txt" 
touch $expected
result="result.txt"
touch $result

echo "legit.pl init:\nInitialized empty legit repository in .legit" >> $expected
echo "legit.pl add $test_file_1 $test_file_2 $test_file_3:" >> $expected
echo "legit.pl commit -m 'commit 1':\nCommitted as commit 0" >> $expected
echo "legit.pl rm --force $test_file_2:" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_2 - deleted\n$test_file_3 - same as repo\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl log:\n0 commit 1" >> $expected
echo "legit.pl add $test_file_1 $test_file_2 $test_file_3:\nlegit.pl: error: can not open '$test_file_2'" >> $expected
echo "legit.pl add $test_file_1 $test_file_3:" >> $expected
echo "legit.pl commit -m commit02:\nCommitted as commit 1" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_3 - same as repo\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl rm --cached $test_file_3:" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_3 - untracked\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl rm $test_file_3:\nlegit.pl: error: '$test_file_3' is not in the legit repository" >> $expected
echo "legit.pl rm --force $test_file_3:\nlegit.pl: error: '$test_file_3' is not in the legit repository" >> $expected


echo "legit.pl init:" >> $result
perl legit.pl init >> $result
echo 123456 > $test_file_1
echo abcdefg > $test_file_2
echo line1 > $test_file_3
echo "legit.pl add $test_file_1 $test_file_2 $test_file_3:" >> $result
perl legit.pl add $test_file_1 $test_file_2 $test_file_3 >> $result
echo "legit.pl commit -m 'commit 1':" >> $result
perl legit.pl commit -m 'commit 1' >> $result
echo "legit.pl rm --force $test_file_2:" >> $result
perl legit.pl rm --force $test_file_2 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl log:" >> $result
perl legit.pl log >> $result
echo another >> $test_file_1
echo "legit.pl add $test_file_1 $test_file_2 $test_file_3:" >> $result
perl legit.pl add $test_file_1 $test_file_2 $test_file_3 >> $result
echo "legit.pl add $test_file_1 $test_file_3:" >> $result
perl legit.pl add $test_file_1 $test_file_3 >> $result
echo "legit.pl commit -m commit02:" >> $result
perl legit.pl commit -m commit02 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl rm --cached $test_file_3:" >> $result
perl legit.pl rm --cached $test_file_3 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl rm $test_file_3:" >> $result
perl legit.pl rm $test_file_3 >> $result
echo "legit.pl rm --force $test_file_3:" >> $result
perl legit.pl rm --force $test_file_3 >> $result



if diff $result $expected >/dev/null
then
	echo "pass!"
else
	echo "failed"
	diff -y $result $expected
fi