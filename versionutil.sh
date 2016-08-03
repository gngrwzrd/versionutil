#!/bin/bash

output_help() {
	echo "man versionutil"
}

validate_minor() {
	VALIDATE_NEW_MINOR="$1"
	validate_minor_regex="^([0-9]*)|~?$"
	if [[ "$VALIDATE_NEW_MINOR" =~ $validate_minor_regex ]]; then
		:
	else
		echo "Invalid version format"
		exit 1
	fi
}

validate_patch() {
	VALIDATE_NEW_PATCH="$1"
	validate_patch_regex="^([0-9]*)|~?$"
	if [[ "$VALIDATE_NEW_PATCH" =~ $validate_patch_regex ]]; then
		:
	else
		echo "Invalid version format"
		exit 1
	fi
}

validate_tag() {
	VALIDATE_TAG="$1"
	if [ "$VALIDATE_TAG" ]; then
		validate_tag_regex="^[-|+][a-zA-Z0-9]*$"
		if [[ "$VALIDATE_TAG" =~ $validate_tag_regex ]]; then
			:
		else
			echo "Invalid version format"
			exit 1
		fi
	fi
}

getForce() {
	if [ -z "$1" ]; then
		echo ''
		return
	fi
	force_version=$1
	force_regex="^(!)?"
	if [[ $force_version =~ $force_regex ]]; then
		force_version="${BASH_REMATCH[1]}"
	fi
	echo "$force_version"
}

getMajor() {
	if [ -z "$1" ]; then
		echo ''
		return
	fi
	major_major=''
	major_version=$1
	major_regex="^(!)?([0-9]*|~?)"
	if [[ $major_version =~ $major_regex ]]; then
		major_major="${BASH_REMATCH[2]}"
	fi
	echo "$major_major"
}

getMinor() {
	if [ -z "$1" ]; then
		echo ''
		return
	fi
	minor_minor=''
	minor_version=$1
	minor_regex="^(!)?([0-9]*|~?)\.([0-9]*|~?)"
	if [[ $minor_version =~ $minor_regex ]]; then
		minor_minor="${BASH_REMATCH[3]}"
	fi
	echo "$minor_minor"
}

getPatch() {
	if [ -z "$1" ]; then
		echo ''
		return
	fi
	patch_patch=''
	patch_version=$1
	if [ "$FORMAT" = "long" ]; then
		patch_regex="^(!)?([0-9]*|~?)\.([0-9]*|~?)\.([0-9]*|~?)"
		if [[ $patch_version =~ $patch_regex ]]; then
			patch_patch="${BASH_REMATCH[4]}"
			echo "$patch_patch"
		fi
	elif [ "$FORMAT" = "short" ]; then
		echo ""
	fi
}

getTag() {
	if [ -z "$1" ]; then
		echo ''
		return
	fi
	tag_tag=''
	tag_version=$1
	if [ "$FORMAT" = "long" ]; then
		tag_regex="^(!)?([0-9]*|~?)\.([0-9]*|~?)\.([0-9]*|~?)([-+:0-9a-zA-Z]*)?"
		if [[ $tag_version =~ $tag_regex ]]; then
			tag_tag="${BASH_REMATCH[5]}"
		fi
	elif [ "$FORMAT" = "short" ]; then
		tag_regex="^(!)?([0-9]*|~?)\.([0-9]*|~?)([-+:0-9a-zA-Z]*)?"
		if [[ $tag_version =~ $tag_regex ]]; then
			tag_tag="${BASH_REMATCH[4]}"
		fi
	fi
	echo "$tag_tag"
}

compare() {
	compare=$1
	left_major=$2
	left_minor=$3
	left_patch=$4
	right_major=$5
	right_minor=$6
	right_patch=$7
	if [ "$compare" = "compare" ]; then

		if [ "$FORMAT" = "long" ]; then
			if [ "$left_major" = "$right_major" ] && [ "$left_minor" = "$right_minor" ] && [ "$left_patch" = "$right_patch" ]; then
				echo "eq"
				return
			fi
		elif [ "$FORMAT" = "short" ]; then
			if [ "$left_major" = "$right_major" ] && [ "$left_minor" = "$right_minor" ]; then
				echo "eq"
				return
			fi
		fi

		if (( left_major > right_major )); then
			echo "gt"
			return
		elif (( left_major < right_major )); then
			echo "lt"
			return;
		fi

		if (( left_minor > right_minor )); then
			echo "gt"
			return
		elif (( left_minor < right_minor )); then
			echo "lt"
			return
		fi

		if [ "$FORMAT" = "long" ]; then
			if (( left_patch > right_patch )); then
				echo "gt"
				return
			fi
		fi

		echo "lt"
		return
	fi

	if [ "$compare" = "lt" ]; then
		if (( "$right_major" < "$left_major" )); then
			echo "false"
			return
		fi
		if (( "$right_minor" < "$left_minor" )); then
			echo "false"
			return
		fi
		if [ "$FORMAT" = "long" ]; then
			if (( "$right_patch" < "$left_patch" )); then
				echo "false"
				return
			fi
		fi
		echo "true"
		return
	fi

	if [ "$compare" = "gt" ]; then
		if (( "$right_major" > "$left_major" )); then
			echo "false"
			return
		fi
		if (( "$right_minor" > "$left_minor" )); then
			echo "false"
			return
		fi
		if [ "$FORMAT" = "long" ]; then
			if (( "$right_patch" > "$left_patch" )); then
				echo "false"
				return
			fi
		fi
		echo "true"
		return
	fi

	if [ "$compare" = "eq" ]; then
		if [ "$FORMAT" = "long" ]; then
			if [ "$left_major" = "$right_major" ] && [ "$left_minor" = "$right_minor" ] && [ "$left_patch" = "$right_patch" ]; then
				echo "true"
				return
			fi
		elif [ "$FORMAT" = "short" ]; then
			if [ "$left_major" = "$right_major" ] && [ "$left_minor" = "$right_minor" ]; then
				echo "true"
				return
			fi
		fi

		echo "false"
	fi
}

assert() {
	echo "assert $1 == $2"
	if [ "$1" != "$2" ]; then
		echo "Assert fail $1 != $2"
		exit 1
	fi
}

echo_test() {
	echo "$1"
}

#set default vars
INC_MAJOR=false
INC_MINOR=false
INC_PATCH=false
PRINT_MAJOR=false
PRINT_MINOR=false
PRINT_PATCH=false
PRINT_TAG=false
COMPARE=''
COMPARE_WITH=''
export FORMAT=''

#parse args
for i in "$@"
do
	case "$i" in
	+major|^major)
		INC_MAJOR=true
		;;
	+minor|^minor)
		INC_MINOR=true
		;;
	+patch|^patch)
		INC_PATCH=true
		;;
	--print-major)
		PRINT_MAJOR=true
		;;
	--print-minor)
		PRINT_MINOR=true
		;;
	--print-patch)
		PRINT_PATCH=true
		;;
	--print-tag)
		PRINT_TAG=true
		;;
	--lt)
		COMPARE='lt'
		COMPARE_WITH=$3
		;;
	--gt)
		COMPARE='gt'
		COMPARE_WITH=$3
		;;
	--eq)
		COMPARE='eq'
		COMPARE_WITH=$3
		;;
	--compare)
		COMPARE='compare'
		COMPARE_WITH=$3
		;;
	-h|--help)
		output_help
		exit 0
		;;
	esac
done

#setup format regexes
short_regex="^(!)?([0-9]*|~?)\.([0-9]*|~?)([-+:0-9a-zA-Z]*)?$"
long_regex="^(!)?([0-9]*|~?)\.([0-9]*|~?)\.([0-9]*|~?)([-+:0-9a-zA-Z]*)?$"

#grab version from args and validate it against regex
VERSION=$1

#validate args against short or long regex
if [[ $VERSION =~ $short_regex ]]; then
	export FORMAT='short'
fi
if [[ $VERSION =~ $long_regex ]]; then
	export FORMAT='long'
fi
if [ -z "$FORMAT" ]; then
	echo "Invalid version format"
	exit 1
fi

#grab components from version
FORCE=$(getForce "$VERSION")
MAJOR=$(getMajor "$VERSION")
MINOR=$(getMinor "$VERSION")
PATCH=$(getPatch "$VERSION")
TAG=$(getTag "$VERSION")
NEW_MAJOR=$MAJOR
NEW_MINOR=$MINOR
NEW_PATCH=$PATCH
MAJOR_ZEROED=''
MINOR_ZEROED=''
PATCH_ZEROED=''

#check for ~ to reset major to 0
if [ "$MAJOR" = "~" ]; then
	NEW_MAJOR='0'
	MAJOR_ZEROED='true'
fi

#check for ~ to reset minor to 0
if [ "$MINOR" = "~" ]; then
	NEW_MINOR='0'
	MINOR_ZEROED='true'
fi

#check for ~ to reset patch to 0
if [ "$NEW_PATCH" = "~" ]; then
	NEW_PATCH='0'
	PATCH_ZEROED='true'
fi

#increment major if force isn't present
if [ "$INC_MAJOR" = 'true' ] && [ -z "$FORCE" ] && [ -z "$MAJOR_ZEROED" ]; then
	NEW_MAJOR=$((NEW_MAJOR + 1))
fi

#increment minor if force isn't present
if [ "$INC_MINOR" = 'true' ] && [ -z "$FORCE" ] && [ -z "$MINOR_ZEROED" ]; then
	NEW_MINOR=$((NEW_MINOR + 1))
fi

#increment patch if force isn't present
if [ "$INC_PATCH" = "true" ] && [ -z "$FORCE" ] && [ -z "$PATCH_ZEROED" ] && [ "$FORMAT" != "short" ]; then
	NEW_PATCH=$((NEW_PATCH + 1))
fi

#the regexes to grab each component are a little loose (on purpose),
#validate each component against a stricter regex to ensure proper formatting.

if [ ! "$NEW_MAJOR" ]; then
	echo "Invalid version format"
	exit 1
fi

if [ ! "$NEW_MINOR" ]; then
	echo "Invalid version format"
	exit 1
fi

#validate version for short format
if [ "$FORMAT" = "short" ]; then
	validate_minor $NEW_MINOR
	validate_tag "$TAG"
fi

#validate version for long format
if [ "$FORMAT" = "long" ]; then
	if [ ! "$NEW_PATCH" ]; then
		echo "Invalid version format"
		exit 1
	fi
	validate_patch $NEW_PATCH
	validate_minor $NEW_MINOR
	validate_tag "$TAG"
fi

#print major
if [ "$PRINT_MAJOR" = true ]; then
	echo $NEW_MAJOR
	exit 0;
fi

#print minor
if [ "$PRINT_MINOR" = true ]; then
	echo $NEW_MINOR
	exit 0
fi

#print patch
if [ "$PRINT_PATCH" = true ]; then
	echo $NEW_PATCH
	exit 0
fi

#print tag
if [ "$PRINT_TAG" = true ]; then
	echo "$TAG"
	exit 0
fi

#compare
if [ ! -z "$COMPARE" ]; then

	# #make sure comparison formats match
	compare_format=""

	if [[ "$COMPARE_WITH" =~ $short_regex ]]; then
		compare_format="short"
	fi

	if [[ "$COMPARE_WITH" =~ $long_regex ]]; then
		compare_format="long"
	fi

	if [ "$FORMAT" != "$compare_format" ]; then
		echo "Invalid version format"
		exit 1
	fi

	#grab components
	compare_major=$(getMajor "$COMPARE_WITH")
	compare_minor=$(getMinor "$COMPARE_WITH")
	compare_patch=$(getPatch "$COMPARE_WITH")

	if [ ! "$compare_major" ]; then
		echo "Invalid version format"
		exit 1
	fi

	if [ ! "$compare_minor" ]; then
		echo "Invalid version format"
		exit 1
	fi

	if [ "$compare_format" = "long" ] && [ -z "$compare_patch" ]; then
		echo "Invalid version format"
		exit 1
	fi

	if [  "$compare_major" = "~" ]; then
		compare_major="0"
	fi

	if [ "$compare_minor" = "~" ]; then
		compare_minor="0"
	fi

	if [ "$compare_patch" = "~" ]; then
		compare_patch="0"
	fi

	if [ "$compare_format" = "long" ]; then
		validate_patch $compare_patch
	fi

	result=$(compare "$COMPARE" "$NEW_MAJOR" "$NEW_MINOR" "$NEW_PATCH" "$compare_major" "$compare_minor" "$compare_patch")
	echo "$result"
	exit 0
fi

#create new version
if [ "$TAG" ]; then
	if [ "$FORMAT" = "long" ]; then
		echo "$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH$TAG"
	elif [ "$FORMAT" = "short" ]; then
		echo "$NEW_MAJOR.$NEW_MINOR$TAG"
	fi
else
	if [ "$FORMAT" = "long" ]; then
		echo "$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"
	elif [[ "$FORMAT" = "short" ]]; then
		echo "$NEW_MAJOR.$NEW_MINOR"
	fi
fi
