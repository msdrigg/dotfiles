#!/bin/bash
cd "$(dirname "${BASH_SOURCE}")";

git pull origin main;

# We still need this.
windows() { [[ -n "$WINDIR" ]]; }

# Cross-platform symlink function. With one parameter, it will check
# whether the parameter is a symlink. With two parameters, it will create
# a symlink to a file or directory, with syntax: link $linkname $target
link() {
    if [[ -z "$2" ]]; then
        # Link-checking mode.
        if windows; then
            fsutil reparsepoint query "$1" > /dev/null
        else
            [[ -h "$1" ]]
        fi
    else
        # Link-creation mode.
        if windows; then
            # Windows needs to be told if it's a directory or not. Infer that.
            # Also: note that we convert `/` to `\`. In this case it's necessary.
            if [[ -d "$2" ]]; then
                cmd <<< "mklink /D \"$1\" \"${2//\//\\}\"" > /dev/null
            else
                cmd <<< "mklink \"$1\" \"${2//\//\\}\"" > /dev/null
            fi
        else
            # You know what? I think ln's parameters are backwards.
            ln -s "$2" "$1"
        fi
    fi
}

function doIt() {
	# Common aliases
	if command -v rsync &> /dev/null
	then
	  echo "Using rsync as default syncing command"
	  rsync --exclude ".git/" \
	  	--exclude ".DS_Store" \
		--exclude "local" \
		--exclude ".osx" \
		--exclude "setup.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		-avh --no-perms . ~;
	else
	  echo "Using cp as fallback syncing command because rsync was not found"
	  echo "Only copying .gitconfig, .bashrc, .profile, by default"
	  echo "Install rsync and add it to the path variable to copy everything"
	  cp .bashrc ~
	  cp .gitconfig ~
	  cp .profile ~
	fi

	local BASHSCRIPT="./local/$HOSTNAME/.bash_local"
	if [ -f $BASHSCRIPT ]; then
		echo "Copying local bash script from $BASHSCRIPT"
		cp "$BASHSCRIPT" ~/.bash_local;
	fi
	local LOCALSETUP="./local/$HOSTNAME/setup.sh"
	if [ -f $LOCALSETUP ]; then
		echo "Running local setup script at $LOCALSETUP"
		source "$LOCALSETUP";
	fi

	echo "Setting up link to diff-so-fancy"
	link "$HOME/bin/diff-so-fancy" "diff-so-fancy/diff-so-fancy"

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
read -p "Pausing, press enter to continue"
