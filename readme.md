# Version Util

Increments, prints, and compares version numbers

# Supported Version Formats

versionutil supports short and long versions.

Short versions contain at least major.minor, and an optional tag.

````
1.1
1.1-alpha
1.1+beta
1.1+beta06
2.0-rc1
````

Long versions contain at least major.minor.patch, and an optional tag.

````
2.1.1
2.1.1-alpha
2.1.1+beta
2.1.1+beta06
2.2.0-rc1
````

# Version Tags

Versions support a tag - a suffix after the version that's appended.

It supports this format only

````
^[-|+][a-zA-Z0-9]*$
````

That is, the version can be formatted like this:

````
short version:
major.minor(^[-|+][a-zA-Z0-9]*$)

long version:
major.minor.patch(^[-|+][a-zA-Z0-9]*$)
````

# Printing Components

You can print components in a version. You can't print more than one component at a time.

````
$versionutil 1.2.3 --print-major
1

$versionutil 1.2.3 --print-minor
2

$versionutil 1.2.3 --print-patch
3

$versionutil 1.2.3-alpha-09 --print-tag
-alpha-09
````

# Comparing Versions

````
$versionutil 1.2.3 --lt 2.3.4
true

$versionutil 1.2.3 --gt 2.3.4
false

$versionutil 1.2.3 --eq 1.2.3
true

$versionutil 1.2.3 --compare 1.2.3
eq

$versionutil 1.2.3 --compare 1.2.4
lt

$versionutil 1.2.3 --compare 1.2.1
gt
````

# Incrementing Components

````
$versionutil 1.2.3 +major
2.2.3

$versionutil 1.2.3 +minor
1.3.3

$versionutil 1.2.3 +patch
1.2.4

$versionutil 1.2.3 +patch +major +minor
2.3.4
````

# Version Tags

Versions can contain tags and the version updater will leave those intact.

````
$versionutil 1.2.3-alpha1 +patch
1.2.4-alpha1

$versionutil 1.2.3+alpha.04 +minor
1.3.3+alpha.04
````

# Modifiers

Modifiers override +major +minor and +patch.

### Zero Reset Modifier

Components of a version can be reset to zero with ~

````
$versionutil 1.2.~
1.2.0

$versionutil 1.~.2 +minor
1.0.2

$versionutil 1.~.~
1.0.0

$versionutil ~.~.~
0.0.0

$versionutil 1.~.3
1.0.3

$versionutil 1.4.~ +patch
1.4.0
````

### Force Version Modifier

The force modifer returns the version without incrementing anything.

This is a way to force a version number to something you want.

````
$versionutil !1.0.0
1.0.0

$versionutil !1.2.3 +patch
1.2.3

$versionutil !1.~.~ +patch
1.0.0
````

### Printing With Modifiers

Component modifiers are applied first before printing them.

````
$versionutil 1.1.~ --print-patch
0

$versionutil !1.~.~ --print-major
1

$versionutil 1.2.3 --print-patch +patch
4
````

# Use Case

My personal use case is Xcode Server and Continuous Integration.

The build server increments the patch component every time a successful integration runs.

Incrementing major or minor requires human intervention.

This script was created to allow customizing the Info.plist
CFBundleShortVersionString and control what happens on the build server when
it calculates the version number.

The build server steps are like this:

````
1. Start Integration
2. Xcode Builds, runs a run script phase as part of build process:

git checkout -- Info.plist
PLIST_VERSION=$(PlistBuddy -c "Print: CFBundleShortVersionString" Info.plist)
NEW_VERSION=$(version-update $PLIST_VERSION +patch)
PlistBuddy -c "Set: CFBundleShortVersionString ${NEW_VERSION}" Info.plist

7. Complete Build
8. Release App
````

By using the CFBundleShortVersionString and passing it to version-update,
it allows for the Info.plist to override the version update if it needs to be
set manually.

For example, setting minor version and resetting the patch to 0 in the Plist would
simply require this:

````
<key>CFBundleShortVersionString</key>
<string>1.2.~</string>
````

Or setting the major and setting everything to 0:
````
<key>CFBundleShortVersionString</key>
<string>!2.0.0</string>
````

# Unit Tests

Run unit tests with:

````
./versionutil --test
````
