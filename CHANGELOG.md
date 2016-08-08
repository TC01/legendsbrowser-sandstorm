# 0.1.1

* Fix external links to use target="_blank" so they function in Sandstorm.
* Fix to process spawning by blocking until services (Java, Flask) come up on
their designated ports, as opposed to waiting a fixed amount of time.
* Revert to reflections 0.9.9 in order to fix a nasty multithreading bug.

# 0.1.0

* Initial release; basic uploader UI written, main functionality works.
* Wrapping Legends Browser 1.0.12.
