## PKGBUILDs for Arch Linux

Each PKGBUILD is stored as a git subtree. This makes it possible to have all
PKGBUILDs in one repository while synchronizing them independently with the AUR.

To add a PKGBUILD from an existing reposity (AUR >4):

	git subtree add -P ${name} ssh://aur@aur4.archlinux.org/${name}.git master

To push to the AUR:

	git subtree push -P ${name} ssh://aur@aur4.archlinux.org/${name}.git master

See `import.sh` for a helper script that will upload AUR4 PKGBUILD from AUR3 and
save the corresponding subtree here.
