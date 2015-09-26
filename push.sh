#!/bin/sh

if [ $# -eq 0 ]; then
	cat<<EOF
Usage: ${0##*/} PACKAGES...

Make sure .SRCINFO is up to date and push PACKAGES to the AUR.
EOF
	exit
fi	

for i; do
	pkg="${i##*/}"
	echo "==> $pkg"
	[ ! -d "$pkg" ] && continue
	cd "$pkg"
	mksrcinfo || continue
	if [ -n "$(git status --porcelain .)" ]; then
		echo >&2 "$pkg has staged changes."
		cd ..
		continue
	fi
	cd ..
	git subtree push -P "$pkg" ssh://aur@aur.archlinux.org/"$pkg".git master
done
