#!/bin/sh

if [ -z "$1" ]; then
	cat<<EOF
Usage: ${0##*/} PACKAGE

Make sure .SRCINFO is up to date and push PACKAGE to the AUR.
EOF
	exit
fi	

pkg="${1##*/}"
[ ! -d "$pkg" ] && exit
cd "$pkg"
mksrcinfo || exit
if [ $(git status --porcelain | grep -cE "^?? $pkg") -ne 0 ]; then
	echo >&2 "$1 has staged changes."
	exit
fi
cd ..
git subtree push -P "$pkg" ssh://aur@aur.archlinux.org/"$pkg".git master
