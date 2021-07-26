#!/bin/bash
set -e

if [ "$1" == "" ]; then
    echo "No arguments supplied to setup_common.sh. Remember, you shouldn't be calling this directly."
    return
fi

cd "$(dirname "${BASH_SOURCE[0]}")";

git pull origin main || echo "Unable to pull most recent dotfiles, exiting" && return

DOTFILES_HOME=$PWD
TARGET_HOME=$1
LOCAL=$2

function syncDirectories() {
    if command -v rsync &> /dev/null; then
        rsync -ah --no-perms "$1/." "$2";
    else
        cp -a "$1"/. "$2";
    fi
}

echo "Syncing common folder"
syncDirectories "$DOTFILES_HOME/common" "$TARGET_HOME"
echo "Syncing $LOCAL folder"
syncDirectories "$DOTFILES_HOME/$LOCAL" "$TARGET_HOME"

echo "Syncing shared folders"
echo "Warning: Not setup yet"
# SHARED=$(cat local/linux/.shared | xargs -iXXX find shared -name "xxx")
# for OBJECT in $SHARED; do
# fif [ -f $OBJECT ]; then
# fif dir
# fcp 
# done

BASHSCRIPT="$DOTFILES_HOME/local/$LOCAL/.bash_local"
if [ -f "$BASHSCRIPT" ]; then
    echo "Copying local bash script from $BASHSCRIPT"
    cp "$BASHSCRIPT" "$TARGET_HOME/.bash_local";
    # shellcheck source=./local/linux/.bash_local
    source "$TARGET_HOME/.bash_local"
fi
LOCALSETUP="$DOTFILES_HOME/local/$LOCAL/setup.sh"
if [ -f "$LOCALSETUP" ]; then
    echo "Running local setup script at $LOCALSETUP"
    # shellcheck source=./local/linux/setup.sh
    source "$LOCALSETUP";
fi

echo "Setting up path to $DOTFILES_HOME/diff-so-fancy in $TARGET_HOME/bin"

mkdir -p "$TARGET_HOME/bin/lib"

syncDirectories "$DOTFILES_HOME/diff-so-fancy/lib" "$TARGET_HOME/bin/lib"
cp "$DOTFILES_HOME/diff-so-fancy/diff-so-fancy" "$TARGET_HOME/bin"

if [ -f "$TARGET_HOME/.profile" ]; then
    echo "Running local setup script at $LOCALSETUP"
    # shellcheck source=./linux/.profile
    source "$TARGET_HOME/.profile";
fi
