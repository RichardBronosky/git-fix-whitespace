#!/bin/bash
usage(){
cat << EOF
git-fix-whitespace - Fixes the whitespace issues that 'git-diff --check' complains about.
Usage:
    $0 --cached
    $0 tree-ish tree-ish
Synopsis:
    In its first form the index is modified to correct the whitespace issues found in the files added to the index.
    In its second form the index is modified to correct the whitespace issues found in the files that changed between the 2 hashes given.

Notes:
 1. In git terminology "tree-sh" refers to anything that can be resolved to a tree, including a hash, tag, branch, or something like HEAD~3 (meaning 3 commits prior to HEAD).
 2. This script does not use perl/awk/sed/etc. to do is modifications. It uses git's own functionality. For this reason it should be very future-proof.

Acknowledgments:
    Copyright (c) 2010 Richard Bronosky
    Offered under the terms of the MIT License.
    http://www.opensource.org/licenses/mit-license.php
    Created while employed by CMGdigital
EOF
}

apply_fail(){
    echo "Failed to apply patch $PATCH"
    echo "Perhaps you tried to do a hash comparison with uncommitted changes in your working tree."
    exit $1
}

err_files(){
    git diff $ARG1 $ARG2 --check | sed -E '/^(\+|-)/d;s/:.*//' | sort | uniq
}

PATCH=$(mktemp ${0##*/}.patch.XXXXXX)
if [[ $# == 1 && "$1" == "--cached" ]]; then
    ARG1=$1
    ARG2=HEAD
elif [[ $# == 2 ]]; then
    ARG1=$1
    ARG2=$2
else
    usage
    exit
fi
git diff $ARG1 $ARG2 > $PATCH
FILES=$(sed '/^+++ /!d;s?^+++ b/??' $PATCH)
echo -e "Files in index with whitespace errors:\n$(err_files 1)"
git apply --whitespace=fix -R $PATCH || apply_fail 1
git apply --whitespace=fix $PATCH || apply_fail 2
git reset HEAD $FILES
git add $FILES
rm $PATCH
if [[ $(err_files 2 | wc -l) -gt 0 ]]; then
    echo -e "Remaining files in index with whitespace errors:\n$(err_files 3)"
fi
