test:
	./versionutil --test

test-debug:
	./versionutil --test --test-debug

install:
	ronn versionutil.1.ronn
	cp versionutil.1 /usr/local/share/man/man1/
	cp versionutil /usr/local/bin
