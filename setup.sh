#!/bin/bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin main;

function doIt() {
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude "local" \
		--exclude ".osx" \
		--exclude "setup.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;
	local BASHSCRIPT="./local/$HOSTNAME/bash_local"
	if [ -f $BASHSCRIPT ]; then
		echo "Copying local bash script from $BASHSCRIPT"
		cp "$BASHSCRIPT" ~/.bash_local;
	fi
	local LOCALSETUP="./local/$HOSTNAME/setup.sh"
	if [ -f $LOCALSETUP ]; then
		echo "Running local setup script at $LOCALSETUP"
		source "$LOCALSETUP";
	fi
	source ~/.profile;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt;
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt;
	fi;
fi;
unset doIt;
