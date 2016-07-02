test:
	update-version --test

install:
	ronn update-version.1.ronn
	cp update-version.1 /usr/local/share/man/man1/
	cp update-version /usr/local/bin
