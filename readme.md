# Version Updater

Increments a version number for you.

# Usage

## Incrementing Major

````
$update-version 1.2.3 +major
#2.2.3
````

## Incrementing Minor

````
$update-version 1.2.3 +minor
#1.3.3
````

## Incrementing Patch

````
$update-version 1.2.3 +patch
#1.2.4
````

## Incrementing Multiple

````
$update-version 1.2.3 +patch +major +minor
#2.3.4
````

# Version Tags

Versions can contain tags and the version updater will leave those intact.

````
$update-version 1.2.3-alpha1 +patch
#1.2.4-alpha1
````

````
$update-version 1.2.3+alpha.04 +minor
#1.3.3+alpha.04
````

# Modifiers

Modifiers override +major +minor and +patch.

## Zero Reset Modifier

Components of a version can be reset to zero with ~

````
$update-version 1.2.~
#1.2.0
````

````
$update-version 1.~.2 +minor
#1.0.2
````

````
$update-version 1.~.~
#1.0.0
````

````
$update-version ~.~.~
#0.0.0
````

````
$update-version 1.~.3
#1.0.3
````

````
$update-version 1.4.~ +patch
#1.4.0
````

## Shebang Modifier

The shebang modifer returns the version without incrementing anything.

This is a way to force a version number to something you want.

````
$update-version !1.0.0
#1.0.0
````

````
$update-version !1.2.3 +patch
#1.2.3
````

````
$update-version !1.~.~ +patch
#1.0.0
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
3. git checkout -- Info.plist
4. PLIST_VERSION=$(PlistBuddy -c "Print: CFBundleShortVersionString" Info.plist)
5. NEW_VERSION=$(version-update $PLIST_VERSION +patch)
6. PlistBuddy -c "Set: CFBundleShortVersionString ${NEW_VERSION}" Info.plist
7. Complete Build
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
./update-version --test
````

