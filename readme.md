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

# Version Tags

Versions can contain tags and the version updater will leave those intact.

````
$update-version 1.2.3-alpha1 +patch
#1.2.4-alpha1
````

# Modifiers

## Zero Reset Modifier

Components of a version can be reset to zero with ~

````
$update-version 1.2.~
#1.2.0
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

## Shebang Modifier

The shebang modifer returns the version without incrementing anything.

This is a way to force a version number to something you want.

It overrides +patch, +minor, and +major.

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

But because I wanted a way to manually intervine with the version number, this script
was created to allow to customizing the Info.plist CFBundleShortVersionString and
control what happens on the build server when it calculates the version number.

The build server steps are like this:

````
version=$(PlistBuddy -c "Print: CFBundleShortVersionString" Info.plist)
version-update $VERSION +patch
PlistBuddy -c "Write: CFBundleShortVersionString" Info.plist
````

By using the CFBundleShortVersionString and passing it to version-update,
it allows for the Info.plist to override the version update if it needs to be
set manually.

For example, setting minor version and restting the patch to 0 in the Plist would
simply require this ````1.2.~````

Or setting the major and setting everything to 0: ````!2.0.0````
