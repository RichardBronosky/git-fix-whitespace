 git diff --cached>patch
 git apply --whitespace=fix -R patch
 git apply --whitespace=fix patch
 git reset HEAD $(sed '/^+++ /!d;s?^+++ b/??' patch)
 git add $(sed '/^+++ /!d;s?^+++ b/??' patch)
