#!/bin/sh

# test 2 checks add, commit, -a -m commit fail, -a -m commit, status, rm, legit rm, status
# check if rm and commit are working

test_folder="test2"
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
echo "expected.txt\n$test_file_1\nlegit.pl\n$result" >> $expected
echo "legit.pl add $test_file_1:" >> $expected
echo "legit.pl commit -m 'commit 1':\nCommitted as commit 0" >> $expected
echo "legit.pl commit -a -m commit2:\nnothing to commit" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - file changed, changes not staged for commit\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl commit -a -m commit3:\nCommitted as commit 1" >> $expected
echo "legit.pl add $test_file_2 $test_file_3:" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_2 - added to index\n$test_file_3 - added to index\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_2 - added to index\n$test_file_3 - added to index\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl rm $test_file_3:\nlegit.pl: error: '$test_file_3' has changes staged in the index" >> $expected
echo "legit.pl commit -a -m commit4:\nCommitted as commit 2" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_3 - same as repo\nlegit.pl - untracked\nresult.txt - untracked" >> $expected



echo "legit.pl init:" >> $result
perl legit.pl init >> $result
echo 123456 > $test_file_1
ls >> $result
echo "legit.pl add $test_file_1:" >> $result
perl legit.pl add $test_file_1 >> $result
echo "legit.pl commit -m 'commit 1':" >> $result
perl legit.pl commit -m 'commit 1' >> $result
echo "legit.pl commit -a -m commit2:" >> $result
perl legit.pl commit -a -m commit2 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo another >> $test_file_1 
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "file2" >> $test_file_2
echo "file3" >> $test_file_3
echo "legit.pl commit -a -m commit3:" >> $result
perl legit.pl commit -a -m commit3 >> $result
echo "legit.pl add $test_file_2 $test_file_3:" >> $result
perl legit.pl add $test_file_2 $test_file_3 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
rm $test_file_2
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl rm $test_file_3:" >> $result
perl legit.pl rm $test_file_3 >> $result
echo "legit.pl commit -a -m commit4:" >> $result
perl legit.pl commit -a -m commit4 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result



if diff $result $expected >/dev/null
then
	echo "pass!"
else
	echo "failed"
	diff -y $result $expected
fi
