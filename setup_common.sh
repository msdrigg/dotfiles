#!/bin/bash
set -e

cd "$(dirname "${BASH_SOURCE}")";

git pull origin main;

DOTFILES_HOME=$PWD
TARGET_HOME=$1
LOCAL=$2

function syncDirectories() {
	if command -v rsync &> /dev/null; then
	  rsync -avh --no-perms $1/. $2;
	else
	  cp -a $1/. $2;
	fi
}

syncDirectories $DOTFILES_HOME/common $TARGET_HOME
syncDirectories $DOTFILES_HOME/$LOCAL $TARGET_HOME

# Sync awesome vim directory into vim_runtime
syncDirectories $DOTFILES_HOME/vimrc $TARGET_HOME/.vim_runtime
# Run command to setup ultimate vimrc
bash $TARGET_HOME/.vim_runtime/install_awesome_vimrc.sh;

local BASHSCRIPT="$DOTFILES_HOME/local/$LOCAL/.bash_local"
if [ -f $BASHSCRIPT ]; then
	echo "Copying local bash script from $BASHSCRIPT"
	cp "$BASHSCRIPT" $TARGET_HOME/.bash_local;
fi
local LOCALSETUP="$DOTFILES_HOME/local/$LOCAL/setup.sh"
if [ -f $LOCALSETUP ]; then
	echo "Running local setup script at $LOCALSETUP"
	source "$LOCALSETUP";
fi

echo "Setting up path to diff-so-fancy"
mkdir $TARGET_HOME/bin/lib
syncDirectories "$DOTFILES_HOME/diff-so-fancy/lib" "$TARGET_HOME/bin/lib"
cp "$DOTFILES_HOME/diff-so-fancy/diff-so-fancy" "$TARGET_HOME/bin"

source $TARGET_HOME/.profile;
