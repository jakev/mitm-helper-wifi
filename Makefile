clean:
	rm *.deb

package:
	cd src; \
		dpkg-buildpackage -us -uc -b
