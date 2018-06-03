clean:
	rm build/*.deb

package:
	dpkg-deb -b mitm-helper-wifi/ build
