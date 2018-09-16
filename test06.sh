#!/bin/sh

# test 6 checks add, commit, rm --cached, branch, rm --cached, checkout, status, add, status, checkout
test_folder="test6"
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
echo "legit.pl branch b1:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "legit.pl commit -m 'commit 1':\nCommitted as commit 0" >> $expected
echo "legit.pl rm --cached $test_file_2:" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_2 - untracked\n$test_file_3 - same as repo\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl branch b1:" >> $expected
echo "legit.pl rm --cached $test_file_3:" >> $expected
echo "legit.pl checkout b1:\nSwitched to branch 'b1'" >> $expected 
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_2 - untracked\n$test_file_3 - untracked\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl add $test_file_2:" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_2 - same as repo\n$test_file_3 - untracked\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl checkout master:\nSwitched to branch 'master'" >> $expected



echo "legit.pl init:" >> $result
perl legit.pl init >> $result
echo 123456 > $test_file_1
echo abcdefg > $test_file_2
echo line1 > $test_file_3
echo "legit.pl add $test_file_1 $test_file_2 $test_file_3:" >> $result
perl legit.pl add $test_file_1 $test_file_2 $test_file_3 >> $result
echo "legit.pl branch b1:" >> $result
perl legit.pl branch b1 >> $result
echo "legit.pl commit -m 'commit 1':" >> $result
perl legit.pl commit -m 'commit 1' >> $result
echo "legit.pl rm --cached $test_file_2:" >> $result
perl legit.pl rm --cached $test_file_2 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl branch b1:" >> $result
perl legit.pl branch b1 >> $result
echo "legit.pl rm --cached $test_file_3:" >> $result
perl legit.pl rm --cached $test_file_3 >> $result
echo "legit.pl checkout b1:" >> $result
perl legit.pl checkout b1 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl add $test_file_2:" >> $result
perl legit.pl add $test_file_2 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl checkout master:" >> $result
perl legit.pl checkout master >> $result




if diff $result $expected >/dev/null
then
	echo "pass!"
else
	echo "failed"
	diff -y $result $expected
fi
