#!/bin/sh

if [ $# -eq 0 ]; then
	cat<<EOF
Usage: ${0##*/} PACKAGES...

Make sure .SRCINFO is up to date and push PACKAGES to the AUR.
EOF
	exit
fi	

for i; do
	pkg="${i%/}"
	pkg="${pkg##*/}"
	echo "==> $pkg"
	[ ! -d "$pkg" ] && continue
	if [ ! -f "$pkg/.SRCINFO" ]; then
		echo >&2 ".SRCINFO not found. Skipping."
		continue
	fi
	cd "$pkg"
	mksrcinfo || continue
	if [ "$(git diff --numstat .SRCINFO | cut -f1)" == "1" ] && [ "$(git diff --numstat .SRCINFO | cut -f2)" == "1" ]; then
		## Only 1 unrequired diff, the date bump.
		git checkout .SRCINFO
	fi
	if [ -n "$(git status --porcelain .)" ]; then
		echo >&2 "$pkg has staged changes."
		cd ..
		continue
	fi
	cd ..
	git subtree push -P "$pkg" ssh://aur@aur.archlinux.org/"$pkg".git master
done
