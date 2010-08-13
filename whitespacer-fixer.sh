ERR=$( git diff-index --cached --check HEAD | sed '/^\(\+\|-\)/d;s/:.*//' | sort | uniq )
echo -e "Files in index with whitespace errors:\n$ERR"
if [[ $# != 2 ]]; then
    git diff --cached > patch
else
    git diff $* > patch
fi
git apply --whitespace=fix -R patch
git apply --whitespace=fix patch
git reset HEAD $(sed '/^+++ /!d;s?^+++ b/??' patch)
git add $(sed '/^+++ /!d;s?^+++ b/??' patch)
ERR=$( git diff-index --cached --check HEAD | sed '/^\(\+\|-\)/d;s/:.*//' | sort | uniq )
if [[ $(echo "$ERR" | wc -l) -gt 0 ]]; then
    echo -e "Remaining files in index with whitespace errors:\n$ERR"
fi
