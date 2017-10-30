# 0.1.5

* Change base image to Fedora 26 Vagrant base.
* Update to Legends Browser 1.13, with several bugfixes.

# 0.1.4

* Change base image to Fedora 25 Vagrant base.
* Update to Legends Browser 1.12.2, with several bugfixes.

# 0.1.3

* Use python-libarchive-c to support more archive types than just zip.
* Fix bug where Flask app crashes if file upload fails.
* Add a small hardcoded time delay between starting Java and querying port.

# 0.1.2

* Fix bug where 2+ versions of legendsbrowser can be started due to multiple
launcher processes being spawned.

# 0.1.1

* Fix external links to use target="_blank" so they function in Sandstorm.
* Fix to process spawning by blocking until services (Java, Flask) come up on
their designated ports, as opposed to waiting a fixed amount of time.
* Revert to reflections 0.9.9 in order to fix a nasty multithreading bug.
* Restart Legends Browser whenever Java dies; this should improve reliability.

# 0.1.0

* Initial release; basic uploader UI written, main functionality works.
* Wrapping Legends Browser 1.0.12.
