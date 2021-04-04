clean:
	rm build/*.deb

package:
	cd src; \
		dpkg-buildpackage -us -uc -b
	mv *_all.deb build/
