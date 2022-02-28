#!/bin/sh

[ -n "$LOGFD" ] && {
	exec >&${LOGFD}
	exec 2>&${LOGFD}
}

echo child pid: $$
echo dir: $(pwd)

if [ $# -eq 0 ]; then
  echo "No Files to Change: Skipping Update"
	exit 0
else
	echo files: "$@"
	generator () {
		for file in "$@"; do
			echo "$file"
		done
	}
fi

git checkout master
git pull origin master

generator "$@" | while read file; do
	dir=$(dirname "$file")
	upstream=$(cd "$dir"; git config --get remote.origin.url | sed -e 's/.git$//')
	relpath=$(cd "$dir"; git ls-files --full-name $(basename "$file"))
	env "upstream=$upstream" "relpath=$relpath" $(dirname $0)/freshpush $(pwd)/$file
done

