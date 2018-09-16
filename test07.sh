#!/bin/sh

# test 7 checks add, commit, branch, rm --forced, modify, branch, checkout, add, commit, status, checkout, add commit, merge, rm, checkout master, merge, status
test_folder="test7"
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
test_file_4="file4"

touch $test_file_1 $test_file_2 $test_file_3 $test_file_4

# The expected result are retrived from reference implementation using the same commands
expected="expected.txt" 
touch $expected
result="result.txt"
touch $result

echo "legit.pl init:\nInitialized empty legit repository in .legit" >> $expected
echo "legit.pl add $test_file_1 $test_file_2 $test_file_3:" >> $expected
echo "legit.pl commit -m 'commit 1':\nCommitted as commit 0" >> $expected
echo "legit.pl branch b1:" >> $expected
echo "legit.pl rm --force $test_file_2:" >> $expected
echo "1\n2\n3\n4\n24\n6\n7\n8\n9\n10" >> $expected
echo "legit.pl branch b2:" >> $expected
echo "legit.pl checkout b1:\nSwitched to branch 'b1'" >> $expected
echo "expected.txt\n$test_file_1\n$test_file_3\n$test_file_4\nlegit.pl\nresult.txt" >> $expected
echo "legit.pl add $test_file_4:" >> $expected
echo "legit.pl commit -m commit-2:\nCommitted as commit 1" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - changes in index\n$test_file_3 - same as repo\n$test_file_4 - changes in index\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl checkout b2:\nlegit.pl: error: Your changes to the following files would be overwritten by checkout:\n$test_file_4" >> $expected
echo "legit.pl commit -a -m commit-3:\nCommitted as commit 2" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_3 - same as repo\n$test_file_4 - same as repo\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl checkout b2:\nSwitched to branch 'b2'" >> $expected
echo "expected.txt\n$test_file_1\n$test_file_2\n$test_file_3\nlegit.pl\nresult.txt" >> $expected
echo "legit.pl merge b1 -m merge-b1-b2:\nCommitted as commit 2" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_3 - same as repo\n$test_file_4 - same as repo\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "114\n2\n3\n4\n24\n6\n7\n8\n9\n1140\n111" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_3 - same as repo\n$test_file_4 - file deleted\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl checkout master:\nSwitched to branch 'master'" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_2 - same as repo\n$test_file_3 - same as repo\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "legit.pl merge b2 -m merge-master-b2:\nCommitted as commit 2" >> $expected
echo "legit.pl status:\nexpected.txt - untracked\n$test_file_1 - same as repo\n$test_file_3 - same as repo\n$test_file_4 - same as repo\nlegit.pl - untracked\nresult.txt - untracked" >> $expected
echo "expected.txt\n$test_file_1\n$test_file_3\n$test_file_4\nlegit.pl\nresult.txt" >> $expected




echo "legit.pl init:" >> $result
perl legit.pl init >> $result
seq 1 10 > $test_file_1
echo abcdefg > $test_file_2
echo line1 > $test_file_3
echo one > $test_file_4
echo two >> $test_file_4
echo "legit.pl add $test_file_1 $test_file_2 $test_file_3:" >> $result
perl legit.pl add $test_file_1 $test_file_2 $test_file_3 >> $result
echo "legit.pl commit -m 'commit 1':" >> $result
perl legit.pl commit -m 'commit 1' >> $result
echo "legit.pl branch b1:" >> $result
perl legit.pl branch b1 >> $result
echo "legit.pl rm --force $test_file_2:" >> $result
perl legit.pl rm --force $test_file_2 >> $result
perl -pi -e 's/5/24/' $test_file_1
cat $test_file_1 >> $result
echo "legit.pl branch b2:" >> $result
perl legit.pl branch b2 >> $result
echo "legit.pl checkout b1:" >> $result
perl legit.pl checkout b1 >> $result
ls >> $result
perl -pi -e 's/1/114/' $test_file_1
echo "legit.pl add $test_file_4:" >> $result
perl legit.pl add $test_file_4 >> $result
echo end of file >> $test_file_4
echo 111 >> $test_file_1
echo "legit.pl commit -m commit-2:" >> $result
perl legit.pl commit -m commit-2 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl checkout b2:" >> $result
perl legit.pl checkout b2 >> $result
echo "legit.pl commit -a -m commit-3:" >> $result
perl legit.pl commit -a -m commit-3 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl checkout b2:" >> $result
perl legit.pl checkout b2 >> $result
ls >> $result
echo "legit.pl merge b1 -m merge-b1-b2:" >> $result
perl legit.pl merge b1 -m merge-b1-b2 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
cat $test_file_1 >> $result
rm $test_file_4
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl checkout master:" >> $result
perl legit.pl checkout master >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl merge b2 -m merge-master-b2:" >> $result
perl legit.pl merge b2 -m merge-master-b2 >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
ls >> $result




if diff $result $expected >/dev/null
then
	echo "pass!"
else
	echo "failed"
	diff -y $result $expected
fi
