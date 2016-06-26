#!/bin/bash

getShebang() {
	if [ -z "$1" ]; then
		echo ''
		return
	fi
	version=$1
	shebang=$(echo $version | python -c '
import re,sys;patch=re.search("^(!)?",sys.stdin.read());
if patch.group(1): print patch.group(1)
else: print ''')
	echo $shebang
}

getMajor() {
	if [ -z "$1" ]; then
		echo ''
		return
	fi
	version=$1
	major=$(echo $version | python -c '
import re,sys;patch=re.search("^(!)?([0-9]*~?)\.",sys.stdin.read());
print patch.group(2)')
	echo $major
}

getMinor() {
	if [ -z "$1" ]; then
		echo ''
		return
	fi
	version=$1
	minor=$(echo $version | python -c '
import re,sys;patch=re.search("^(!)?([0-9]*~?)\.([0-9]*~?)\.",sys.stdin.read());
print patch.group(3)')
	echo $minor
}

getPatch() {
	if [ -z "$1" ]; then
		echo ''
		return
	fi
	version=$1
	patch=$(echo $version | python -c '
import re,sys;
patch=re.search("^(!)?([0-9]*~?)\.([0-9]*~?)\.([0-9]*~?)",sys.stdin.read());
print patch.group(4)')
	echo $patch
}

getTag() {
	if [ -z "$1" ]; then
		echo ''
		return
	fi
	version=$1
	tag=$(echo $version | python -c '
import re,sys;
patch=re.search("(!)?([0-9]*~?)\.([0-9]*~?)\.([0-9]*~?)([\-|\+0-9a-zA-Z\.\-\_]*)?",sys.stdin.read());
print patch.group(5)')
	echo $tag
}

assert() {
	echo "assert $1 == $2"
	if [ "$1" != "$2" ]; then
		echo "Assert fail $1 != $2"
		exit 1
	fi
}

if [ "$1" = '--tests' ] || [ "$1" = '--test' ]; then
	echo "Testing..."

	VERSION='1.2.3'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '2'
	assert $PATCH '3'
	assert $TAG ''

	VERSION='1.2.3-alpha'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '2'
	assert $PATCH '3'
	assert $TAG '-alpha'

	VERSION="1.2.3-alpha+rc1"
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '2'
	assert $PATCH '3'
	assert $TAG '-alpha+rc1'

	VERSION="1.2.3-alpha+rc1.808"
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '2'
	assert $PATCH '3'
	assert $TAG '-alpha+rc1.808'

	VERSION="1.2.3+alpha-rc1.808"
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '2'
	assert $PATCH '3'
	assert $TAG '+alpha-rc1.808'

	VERSION="1.2.3+alpha-rc1.808_beta"
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '2'
	assert $PATCH '3'
	assert $TAG '+alpha-rc1.808_beta'

	VERSION="1.2.3+alpha-rc1.808-beta"
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '2'
	assert $PATCH '3'
	assert $TAG '+alpha-rc1.808-beta'

	VERSION="1.2.3-alpha-rc1"
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '2'
	assert $PATCH '3'
	assert $TAG '-alpha-rc1'

	VERSION="1.2.3-alpha.10"
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '2'
	assert $PATCH '3'
	assert $TAG '-alpha.10'

	VERSION='10.2.3'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '10'
	assert $MINOR '2'
	assert $PATCH '3'
	assert $TAG ''

	VERSION='10.20.30'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '10'
	assert $MINOR '20'
	assert $PATCH '30'
	assert $TAG ''

	VERSION='10.2.30'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '10'
	assert $MINOR '2'
	assert $PATCH '30'
	assert $TAG ''

	VERSION='10.2.30+-alpha'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '10'
	assert $MINOR '2'
	assert $PATCH '30'
	assert $TAG '+-alpha'

	VERSION='10.2.30+-alpha.01rc-alpha'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '10'
	assert $MINOR '2'
	assert $PATCH '30'
	assert $TAG '+-alpha.01rc-alpha'

	VERSION='10.2.300'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '10'
	assert $MINOR '2'
	assert $PATCH '300'
	assert $TAG ''

	VERSION='100.200.300'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '100'
	assert $MINOR '200'
	assert $PATCH '300'
	assert $TAG ''

	VERSION='100.200.300-alpha-1'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '100'
	assert $MINOR '200'
	assert $PATCH '300'
	assert $TAG '-alpha-1'

	VERSION='1.2.~'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '2'
	assert $PATCH '~'
	assert $TAG ''

	VERSION='1.2.~-alpha1'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '2'
	assert $PATCH '~'
	assert $TAG '-alpha1'

	VERSION='1.~.1'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '~'
	assert $PATCH '1'
	assert $TAG ''

	VERSION='1.~.1-alpha2'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '~'
	assert $PATCH '1'
	assert $TAG '-alpha2'

	VERSION='1.~.~-alpha2'
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $MAJOR '1'
	assert $MINOR '~'
	assert $PATCH '~'
	assert $TAG '-alpha2'

	VERSION='!1.~.~-alpha2'
	SHEBANG=$(getShebang $VERSION)
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $SHEBANG '!'
	assert $MAJOR '1'
	assert $MINOR '~'
	assert $PATCH '~'
	assert $TAG '-alpha2'

	VERSION='1.0.0-beta+exp.sha.5114f85'
	SHEBANG=$(getShebang $VERSION)
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $SHEBANG ''
	assert $MAJOR '1'
	assert $MINOR '0'
	assert $PATCH '0'
	assert $TAG '-beta+exp.sha.5114f85'

	VERSION='1.0.0+20130313144700'
	SHEBANG=$(getShebang $VERSION)
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $SHEBANG ''
	assert $MAJOR '1'
	assert $MINOR '0'
	assert $PATCH '0'
	assert $TAG '+20130313144700'

	VERSION='1.~.~-beta+exp.sha.5114f85'
	SHEBANG=$(getShebang $VERSION)
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $SHEBANG ''
	assert $MAJOR '1'
	assert $MINOR '~'
	assert $PATCH '~'
	assert $TAG '-beta+exp.sha.5114f85'

	VERSION='!1.~.~-beta+exp.sha.5114f85'
	SHEBANG=$(getShebang $VERSION)
	MAJOR=$(getMajor $VERSION)
	MINOR=$(getMinor $VERSION)
	PATCH=$(getPatch $VERSION)
	TAG=$(getTag $VERSION)
	assert $SHEBANG '!'
	assert $MAJOR '1'
	assert $MINOR '~'
	assert $PATCH '~'
	assert $TAG '-beta+exp.sha.5114f85'

	output=$(./semantic_versioning.sh 1.3.4-alpha1 +patch)
	assert $output "1.3.5-alpha1"

	output=$(./semantic_versioning.sh 1.2.3 +major +minor +patch)
	assert $output "2.3.4"

	output=$(./semantic_versioning.sh 1.~.2 +minor)
	assert $output "1.1.2"

	output=$(./semantic_versioning.sh '!~.~.~' +major +minor +patch)
	assert $output "0.0.0"

	output=$(./semantic_versioning.sh '!~.~.~' +major)
	assert $output "0.0.0"

	output=$(./semantic_versioning.sh '!~.~.~' +major +minor)
	assert $output "0.0.0"

	output=$(./semantic_versioning.sh '!~.~.~' +minor)
	assert $output "0.0.0"

	output=$(./semantic_versioning.sh '!~.~.~' +minor +patch)
	assert $output "0.0.0"

	output=$(./semantic_versioning.sh '!~.~.~' +patch)
	assert $output "0.0.0"

	output=$(./semantic_versioning.sh 10.10.10)
	assert $output "10.10.10"

	output=$(./semantic_versioning.sh 2.3.4-alpha1.beta2-98ad873 +patch)
	assert $output "2.3.5-alpha1.beta2-98ad873"
	
	output=$(./semantic_versioning.sh 2.3.4-alpha1.beta2-98ad873 +patch +major)
	assert $output "3.3.5-alpha1.beta2-98ad873"

	output=$(./semantic_versioning.sh 2.3.4-alpha1.beta2-98ad873 +patch +major +minor)
	assert $output "3.4.5-alpha1.beta2-98ad873"

	output=$(./semantic_versioning.sh '!2.3.4-alpha1.beta2-98ad873' +patch +major +minor)
	assert $output "2.3.4-alpha1.beta2-98ad873"

	output=$(./semantic_versioning.sh '~.~.~-alpha1.beta2-98ad873' +patch +major +minor)
	assert $output "1.1.1-alpha1.beta2-98ad873"

	output=$(./semantic_versioning.sh '~.2.~-alpha1.beta2-98ad873' +patch +major +minor)
	assert $output "1.3.1-alpha1.beta2-98ad873"

	output=$(./semantic_versioning.sh '~.2.~-alpha1.beta2-98ad873' +patch)
	assert $output "0.2.1-alpha1.beta2-98ad873"

	output=$(./semantic_versioning.sh '!~.~.~-alpha1.beta2-98ad873' +patch +major +minor)
	assert $output "0.0.0-alpha1.beta2-98ad873"

	output=$(./semantic_versioning.sh '1.2.3' ^patch)
	assert $output "1.2.4"

	output=$(./semantic_versioning.sh '1.2.3' ^patch ^minor ^major)
	assert $output "2.3.4"

	echo "all tests passed"
	exit
fi

#grab version from args
VERSION=$1
#TODO: Validate VERSION matches regex

#set default vars
INC_MAJOR=false
INC_MINOR=false
INC_PATCH=false

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
	esac
done

#grab components from version
SHEBANG=$(getShebang $VERSION)
MAJOR=$(getMajor $VERSION)
MINOR=$(getMinor $VERSION)
PATCH=$(getPatch $VERSION)
TAG=$(getTag $VERSION)
NEW_MAJOR=$MAJOR
NEW_MINOR=$MINOR
NEW_PATCH=$PATCH

#check for ~ to reset major to 0
if [ "${MAJOR}" = '~' ]; then
	NEW_MAJOR='0'
fi

#check for ~ to reset minor to 0
if [ "${MINOR}" = '~' ]; then
	NEW_MINOR='0'
fi

#check for ~ to reset patch to 0
if [ "${NEW_PATCH}" = '~' ]; then
	NEW_PATCH='0'
fi

#increment major if shebang isn't present
if [ "$INC_MAJOR" = 'true' ] && [ -z $SHEBANG ]; then
	NEW_MAJOR=$(($NEW_MAJOR + 1))
fi

#increment minor if shebang isn't present
if [ "$INC_MINOR" = 'true' ] && [ -z $SHEBANG ]; then
	NEW_MINOR=$(($NEW_MINOR + 1))
fi

#increment patch if shebang isn't present
if [ "$INC_PATCH" = "true" ] && [ -z $SHEBANG ]; then
	NEW_PATCH=$(($NEW_PATCH + 1))
fi

#create new version
if [ "${TAG}" ]; then
	echo "${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}${TAG}"
else
	echo "${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"
fi
