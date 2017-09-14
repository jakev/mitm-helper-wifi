clean:
	rm build/*.deb

package:
	dpkg-deb -b mitm-helper-wifi_0.2/ build/
