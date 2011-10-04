.PHONY: all world src reinstall test clean lwt uninstall

# Default target: build src directory
all: src

# Convenience target to build library and install it
world: src install test

# Build the library
src:
	make -C $@

# Build/run tests
test:
	make -C $@

# Clean everything
clean:
	make -C src clean
	make -C test clean
	make -C lwt clean

# Uninstall
uninstall:
	make -C src uninstall
	make -C lwt uninstall

lwt:
	make -C lwt all install

# Convenience target to reinstall library and rebuild tests and samples
reinstall: clean uninstall world

%:
	make -C src $@
