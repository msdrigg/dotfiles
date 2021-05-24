#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE}")";

if ! git pull origin main ; then
    echo "Unable to pull most recent dotfiles, exiting"
    exit 0
fi


DOTFILES_HOME=$PWD
TARGET_HOME=$1
LOCAL=$2

function syncDirectories() {
	if command -v rsync &> /dev/null; then
	  rsync -ah --no-perms $1/. $2;
	else
	  cp -a $1/. $2;
	fi
}

echo "Syncing common folder"
syncDirectories $DOTFILES_HOME/common $TARGET_HOME
echo "Syncing $LOCAL folder"
syncDirectories $DOTFILES_HOME/$LOCAL $TARGET_HOME

BASHSCRIPT="$DOTFILES_HOME/local/$LOCAL/.bash_local"
if [ -f $BASHSCRIPT ]; then
	echo "Copying local bash script from $BASHSCRIPT"
	cp "$BASHSCRIPT" $TARGET_HOME/.bash_local;
	source $TARGET_HOME/.bash_local
fi
LOCALSETUP="$DOTFILES_HOME/local/$LOCAL/setup.sh"
if [ -f $LOCALSETUP ]; then
	echo "Running local setup script at $LOCALSETUP"
	source "$LOCALSETUP";
fi

echo "Setting up path to $DOTFILES_HOME/diff-so-fancy in $TARGET_HOME/bin"

mkdir -p $TARGET_HOME/bin/lib

syncDirectories "$DOTFILES_HOME/diff-so-fancy/lib" "$TARGET_HOME/bin/lib"
cp "$DOTFILES_HOME/diff-so-fancy/diff-so-fancy" "$TARGET_HOME/bin"

if [ -f $TARGET_HOME/.profile ]; then
	echo "Running local setup script at $LOCALSETUP"
	source $TARGET_HOME/.profile;
fi
