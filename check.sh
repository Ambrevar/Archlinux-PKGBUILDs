#!/bin/sh

get_options() {
	## Skip empty lines and comments at the beginning.
	echo "$1" | awk 'BEGIN {begin=1} begin && (/^[[:space:]]*$/ || /^[[:space:]]*#/) {next} ! /^[[:space:]]*$/ {begin=0;print;next} {exit}'
}

check_braces() {
	echo "$1" | awk '/\${/ {sub(/^[[:space:]]*/,"");print "Braced variable: " $0}'
}

check_install() {
	echo "$1" | awk '/^[[:space:]]*install / {if ($2 == "-Dm755" || $2 == "-Dm644") next; if ($2 == "-dm755" && NF == 3) next; if (($2 == "-m644" || $2 == "-m755") && (NF > 4 || (NF==4 && match($3,/\*/)))) next; sub(/^[[:space:]]*/,"");print "Dubious `install` call: " $0}'
}

check_maintainer() {
	echo "$1" | awk 'BEGIN {m="# Maintainer: Pierre Neidhardt <ambrevar@gmail.com>"} NR==1 && $0 != m {print "Wrong maintainer. Expecting [" m "]"} {exit}'
}

check_order() {
	echo "$1" | awk -F '=' 'BEGIN {
	o["_pkgname"]=1
	o["pkgname"]=2
	o["pkgver"]=3
	o["pkgrel"]=4
	o["pkgdesc"]=5
	o["arch"]=6
	o["url"]=7
	o["license"]=8
	o["groups"]=9
	o["depends"]=10
	o["makedepends"]=11
	o["optdepends"]=12
	o["provides"]=13
	o["conflicts"]=14
	o["replaces"]=15
	o["backup"]=16
	o["options"]=17
	o["install"]=18
	o["changelog"]=19
	o["source"]=20
	o["noextract"]=21
	o["md5sums"]=22
	o["sha1sums"]=22
	o["sha256sums"]=22
	o["sha384sums"]=22
	o["sha512sums"]=22
}
/^[^[:space:]]/ {
	if (o[$1] <= prev) {
		print $1 " is not properly ordered."
	}
	prev = o[$1]
}'
}

check_quotes() {
	echo "$1" | awk '/^pkgdesc/ {flag=1} (!flag || /^options/) {if(/"/ || /'"'"'/) print "Unquote option: " $0; next} {if(!/"/ || /'"'"'/) {print "Use double quotes: " $0}}'
}

check_return() {
	## No need to print where, there should not be any 'return'.
	if [ -n "$(echo "$1" | grep -m1 '\<return\>')" ]; then
		echo "Found 'return' statement(s)."
	fi
}

check_tabs() {
	if [ -n "$(echo "$1" | grep -m1 '^ ')" ] ; then
		echo "Found indenting space."
	fi
}

check_trailing() {
	if [ -n "$(echo "$1" | grep -m1 '[[:space:]]$')" ] ; then
		echo "Found trailing space."
	fi
}

check_unquoted_var() {
	echo "$1" | awk '/ \$srcdir|=\$srcdir| \$pkgdir|=\$pkgdir/ {sub(/^[[:space:]]*/,"");print "Found unquoted variable: " $0}'
}

check() {
	echo "==> $1"
	pkgbuild="$(cat $1)"
	options="$(get_options "$pkgbuild")"
	check_braces "$pkgbuild"
	check_install "$pkgbuild"
	check_maintainer "$pkgbuild"
	check_order "$options"
	check_quotes "$options"
	check_return "$pkgbuild"
	check_tabs "$pkgbuild"
	check_trailing "$pkgbuild"
	check_unquoted_var "$pkgbuild"
	namcap "$1"
}

if [ $# -eq 0 ]; then
	while IFS= read -r i; do
		check "$i"
	done <<EOF
$(find -name PKGBUILD)
EOF
else
	for i; do
		check "$i"
	done
fi
