cbin:
	clang -g -O0 versionutil.c -o versionutil

#lib:
#	clang

test-c:
	./test './versionutil'

test-sh:
	./test ./versionutil.sh

install:
	ronn versionutil.1.ronn
	cp versionutil.1 /usr/local/share/man/man1/
	cp versionutil /usr/local/bin
