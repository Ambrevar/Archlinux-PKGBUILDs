#!/bin/sh

## Quick-and-dirty import script for the AUR 3 to 4 transition.
## There is no much need in polishing this any further since it will be used only once.

if [ -z "$1" ]; then
	echo >&2 "Provide a PKGBUILD name."
	exit
fi	

export name="$1"
source="$HOME/projects/archlinux-pkgbuilds-archive"

if [ -e "/tmp/aurimport/$name" ]; then
	echo >&2 "Folder /tmp/aurimport/$name already exists!"
	exit
fi

OLDDIR="$(pwd)"

mkdir -p "/tmp/aurimport"
cd "/tmp/aurimport"
git clone ssh://aur@aur4.archlinux.org/${name}.git
[ $? -ne 0 ] && exit
cd "$name"
## WARNING: We assume there is no hidden files and no folders to copy.
cp "$source"/"$name"/* .
[ $? -ne 0 ] && exit
mksrcinfo
[ $? -ne 0 ] && exit
git add * .SRCINFO
git commit -a -m 'Init'
git push ssh://aur@aur4.archlinux.org/${name}.git
[ $? -ne 0 ] && exit
rm -rf "/tmp/aurimport/$name"

cd "$OLDDIR"

## The PKGBUILD repo is added in a git subtree of this repo.
git subtree add -P $name ssh://aur@aur4.archlinux.org/${name}.git master
