#!/bin/bash

# Get most recent tag 
tag_name=$(git describe --abbrev=0 --tags);

# Delete tag from remote
git push --delete origin $tag_name &> /dev/null;
updated_tag="FALSE"

if ! [ $(git describe HEAD) == $tag_name ]; then
    # Tag commit is not at HEAD, so we will ask user about which to use
    regex="$tag_name-([0-9]+)-g.*";
    [[ $(git describe HEAD) =~ $regex ]];
    commit_number=${BASH_REMATCH[1]};
    echo "Tag $tag_name is currently $commit_number commits behind HEAD. ";
    echo "We can re-release $tag_name at its current commit or re-release at HEAD.";
    read -n1 -p "Should we release at current commit? [Y,n]: " doit;
    case $doit in
      n|N|no|No|NO) use_current=NO ;; 
      *) use_current=YES ;; 
    esac

    if ! [ "$use_current" == "YES" ]; then
        echo "Updating tag $tag_name to HEAD";
        msg=$(git tag -l --format='%(contents)' $tag_name);
        git tag -d $tag_name;
        git tag -a $tag_name -m "$msg";
        updated_tag="TRUE";
    fi
fi

if ! [ updated_tag == "TRUE" ]; then
    echo "Re-creating tag at current commit";
fi

echo "Pushing commits and tags"
git push &> /dev/null;
git push --tags &> /dev/null;
