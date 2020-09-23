# The default target
.PHONY: all toolchain
all:
toolchain:

# Make uses /bin/sh by default, ignoring the user's value of SHELL.
# Some systems now ship with /bin/sh pointing at dash, and this Makefile
# requires bash
SHELL = /bin/bash

PREFIXPATH ?=
BINDIR := bin
OBJDIR := obj
SRCDIR := $(PREFIXPATH)src
PATCHESDIR := $(PREFIXPATH)patches
SCRIPTSDIR := $(PREFIXPATH)scripts

UBUNTU32 ?= i686-linux-ubuntu14
UBUNTU64 ?= x86_64-linux-ubuntu14
REDHAT ?= x86_64-linux-centos6
WIN32  ?= i686-w64-mingw32
WIN64  ?= x86_64-w64-mingw32
DARWIN ?= x86_64-apple-darwin


-include /etc/lsb-release
ifneq ($(wildcard /etc/redhat-release),)
NATIVE ?= $(REDHAT)
all: redhat
toolchain: redhat-toolchain
else ifeq ($(DISTRIB_ID),Ubuntu)
ifeq ($(shell uname -m),x86_64)
NATIVE ?= $(UBUNTU64)
all: ubuntu64
toolchain: ubuntu64-toolchain
else
NATIVE ?= $(UBUNTU32)
all: ubuntu32
toolchain: ubuntu32-toolchain
endif
all: win64
toolchain: win64-toolchain
else ifeq ($(shell uname),Darwin)
NATIVE ?= $(DARWIN)
LIBTOOLIZE ?= glibtoolize
TAR ?= gtar
SED ?= gsed
AWK ?= gawk
all: darwin
toolchain: darwin-toolchain
else
$(error Unknown host)
endif

LIBTOOLIZE ?= libtoolize
TAR ?= tar
SED ?= sed
AWK ?= awk

OBJ_NATIVE   := $(OBJDIR)/$(NATIVE)
OBJ_UBUNTU32 := $(OBJDIR)/$(UBUNTU32)
OBJ_UBUNTU64 := $(OBJDIR)/$(UBUNTU64)
OBJ_WIN32    := $(OBJDIR)/$(WIN32)
OBJ_WIN64    := $(OBJDIR)/$(WIN64)
OBJ_DARWIN   := $(OBJDIR)/$(DARWIN)
OBJ_REDHAT   := $(OBJDIR)/$(REDHAT)

SRC_RBU      := $(SRCDIR)/riscv-binutils
SRC_RGCC     := $(SRCDIR)/riscv-gcc
SRC_RGDB     := $(SRCDIR)/riscv-gdb
SRC_RNL      := $(SRCDIR)/riscv-newlib

# The version that will be appended to the various tool builds.
RGT_VERSION ?= 10.1.0-2020.08.2
RGDB_VERSION ?= 9.1.0-2020.08.2
RGDBP_VERSION ?= 9.1.0-2020.08.2
RGBU_VERSION ?= 2.35.0-2020.08.2

# The toolchain build needs the tools in the PATH, and the windows build uses the ubuntu (native)
PATH := $(abspath $(OBJ_NATIVE)/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(NATIVE)/bin):$(PATH)
export PATH

# The actual output of this repository is a set of tarballs.
.PHONY: win64 win64-toolchain
win64: win64-toolchain
win64-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(WIN64).zip
win64-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(WIN64).src.zip
win64-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(WIN64).tar.gz
win64-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(WIN64).src.tar.gz
.PHONY: win32 win32-toolchain
win32: win32-toolchain
win32-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(WIN32).zip
win32-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(WIN32).src.zip
win32-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(WIN32).tar.gz
win32-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(WIN32).src.tar.gz
.PHONY: ubuntu64 ubuntu64-toolchain
ubuntu64: ubuntu64-toolchain
ubuntu64-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(UBUNTU64).tar.gz
ubuntu64-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(UBUNTU64).src.tar.gz
.PHONY: ubuntu32 ubuntu32-toolchain
ubuntu32: ubuntu32-toolchain
ubuntu32-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(UBUNTU32).tar.gz
ubuntu32-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(UBUNTU32).src.tar.gz
.PHONY: redhat redhat-toolchain
redhat: redhat-toolchain
redhat-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(REDHAT).tar.gz
redhat-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(REDHAT).src.tar.gz
.PHONY: darwin darwin-toolchain
darwin: darwin-toolchain
darwin-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(DARWIN).tar.gz
darwin-toolchain: $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(DARWIN).src.tar.gz


# Some special riscv-gnu-toolchain configure flags for specific targets.
$(WIN32)-rgt-host            := --host=$(WIN32)
$(WIN32)-rgcc-configure      := --without-system-zlib
$(WIN32)-expat-configure     := --host=$(WIN32)
$(WIN64)-rgt-host            := --host=$(WIN64)
$(WIN64)-rgcc-configure      := --without-system-zlib
$(WIN64)-rgdb-python         := --with-python="$(abspath $(OBJ_WIN64)/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(WIN64))/python/pyconfig-mingw32.sh"
$(WIN64)-rgdb-only-python    := --with-python="$(abspath $(OBJ_WIN64)/install/riscv64-unknown-elf-gdb-$(RGDBP_VERSION)-$(WIN64))/python/pyconfig-mingw32.sh"
$(UBUNTU32)-rgt-host         := --host=i686-linux-gnu
$(UBUNTU32)-rgcc-configure   := --with-system-zlib
$(UBUNTU32)-expat-configure  := --host=i686-linux-gnu
$(UBUNTU64)-rgt-host         := --host=x86_64-linux-gnu
$(UBUNTU64)-rgcc-configure   := --with-system-zlib
$(UBUNTU64)-rgdb-python      := --with-python="$(abspath $(OBJ_UBUNTU64)/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(UBUNTU64))/python/bin/python3"
$(UBUNTU64)-rgdb-only-python := --with-python="$(abspath $(OBJ_UBUNTU64)/install/riscv64-unknown-elf-gdb-$(RGDBP_VERSION)-$(UBUNTU64))/python/bin/python3"
$(DARWIN)-rgcc-configure     := --with-system-zlib
$(DARWIN)-rgbu-configure     := --with-included-gettext
$(DARWIN)-rgdb-python        := --with-python="$(abspath $(OBJ_DARWIN)/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(DARWIN))/python/bin/python3"
$(DARWIN)-rgdb-only-python   := --with-python="$(abspath $(OBJ_DARWIN)/install/riscv64-unknown-elf-gdb-$(RGDBP_VERSION)-$(DARWIN))/python/bin/python3"
$(REDHAT)-rgcc-configure     := --with-system-zlib
$(REDHAT)-rgdb-python        := --with-python="$(abspath $(OBJ_REDHAT)/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$(REDHAT))/python/pyconfig-centos6.sh"
$(REDHAT)-rgdb-only-python   := --with-python="$(abspath $(OBJ_REDHAT)/install/riscv64-unknown-elf-gdb-$(RGDBP_VERSION)-$(REDHAT))/python/pyconfig-centos6.sh"

# Some general riscv-gnu-toolchain flags and list of multilibs for the multilibs generator script
WITH_ABI := lp64d
WITH_ARCH := rv64imafdc
WITH_CMODEL := medany
NEWLIB_TUPLE := riscv64-unknown-elf
MULTILIBS_GEN := \
	rv32e-ilp32e--c*v*zvqmac \
	rv32ea-ilp32e--m*v*zvqmac \
	rv32em-ilp32e--c*v*zvqmac \
	rv32eac-ilp32e--v*zvqmac \
	rv32emac-ilp32e--v*zvqmac \
	rv32i-ilp32--c*f*d*zfh*v*zvqmac \
	rv32ia-ilp32--m*f*d*v*zfh*zvqmac \
	rv32im-ilp32--c*f*d*zfh*v*zvqmac \
	rv32iac-ilp32--f*d*v*zfh*zvqmac \
	rv32imac-ilp32-rv32imafc,rv32imafdc,rv32imafczfh,rv32imafdczfh-v*zvqmac \
	rv32if-ilp32f--d*c*v*zfh*zvqmac \
	rv32iaf-ilp32f--d*c*v*zfh*zvqmac \
	rv32imf-ilp32f--d*v*zfh*zvqmac \
	rv32imaf-ilp32f-rv32imafd-zfh*v*zvqmac \
	rv32imfc-ilp32f--d*v*zfh*zvqmac \
	rv32imafc-ilp32f-rv32imafdc-v*zfh*zvqmac \
	rv32ifd-ilp32d--c*v*zfh*zvqmac \
	rv32imfd-ilp32d--c*v*zfh*zvqmac \
	rv32iafd-ilp32d-rv32imafd,rv32iafdc-v*zfh*zvqmac \
	rv32imafdc-ilp32d--v*zfh*zvqmac \
	rv64i-lp64--f*d*c*v*zfh*zvqmac \
	rv64ia-lp64--m*f*d*v*zfh*zvqmac \
	rv64im-lp64--f*d*c*v*zfh*zvqmac \
	rv64iac-lp64--f*d*v*zfh*zvqmac \
	rv64imac-lp64-rv64imafc,rv64imafdc,rv64imafczfh,rv64imafdczfh-v*zvqmac \
	rv64if-lp64f--d*c*v*zfh*zvqmac \
	rv64iaf-lp64f--d*c*v*zfh*zvqmac \
	rv64imf-lp64f--d*v*zfh*zvqmac \
	rv64imaf-lp64f-rv64imafd-v*zfh*zvqmac \
	rv64imfc-lp64f--d*v*zfh*zvqmac \
	rv64imafc-lp64f-rv64imafdc-v*zfh*zvqmac \
	rv64ifd-lp64d--c*v*zfh*zvqmac \
	rv64imfd-lp64d--c*v*zfh*zvqmac \
	rv64iafd-lp64d-rv64imafd,rv64iafdc-v*zfh*zvqmac \
	rv64imafdc-lp64d--v*zfh*zvqmac

CFLAGS_FOR_TARGET := $(CFLAGS_FOR_TARGET_EXTRA) -mcmodel=$(WITH_CMODEL)
CXXFLAGS_FOR_TARGET := $(CXXFLAGS_FOR_TARGET_EXTRA) -mcmodel=$(WITH_CMODEL)
# --with-expat is required to enable XML support used by OpenOCD.
BINUTILS_TARGET_FLAGS := --with-expat=yes $(BINUTILS_TARGET_FLAGS_EXTRA) --with-mpc=no --with-mpfr=no --with-gmp=no
GDB_TARGET_FLAGS := --with-expat=yes $(GDB_TARGET_FLAGS_EXTRA) --with-mpc=no --with-mpfr=no --with-gmp=no
NEWLIB_CC_FOR_TARGET ?= $(NEWLIB_TUPLE)-gcc
NEWLIB_CXX_FOR_TARGET ?= $(NEWLIB_TUPLE)-g++

# There's enough % rules that make starts blowing intermediate files away.
.SECONDARY:

# Builds riscv-gnu-toolchain for various targets.
$(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-%.zip: \
		$(OBJDIR)/%/stamps/riscv-gnu-toolchain/install.stamp
	$(eval $@_TARGET := $(patsubst $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-%.zip,%,$@))
	mkdir -p $(dir $@)
	cd $(OBJDIR)/$($@_TARGET)/install; zip -rq $(abspath $@) riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET)

$(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-%.src.zip: \
		$(OBJDIR)/%/stamps/riscv-gnu-toolchain/install.stamp
	$(eval $@_TARGET := $(patsubst $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-%.src.zip,%,$@))
	mkdir -p $(dir $@)
	cd $(OBJDIR)/$($@_TARGET)/build; zip -rq $(abspath $@) riscv-gnu-toolchain expat

$(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-%.tar.gz: \
		$(OBJDIR)/%/stamps/riscv-gnu-toolchain/install.stamp
	$(eval $@_TARGET := $(patsubst $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-%.tar.gz,%,$@))
	mkdir -p $(dir $@)
	$(TAR) --dereference --hard-dereference -C $(OBJDIR)/$($@_TARGET)/install -c riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET) | gzip > $(abspath $@)

$(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-%.src.tar.gz: \
		$(OBJDIR)/%/stamps/riscv-gnu-toolchain/install.stamp
	$(eval $@_TARGET := $(patsubst $(BINDIR)/riscv64-unknown-elf-gcc-$(RGT_VERSION)-%.src.tar.gz,%,$@))
	mkdir -p $(dir $@)
	$(TAR) --dereference --hard-dereference -C $(OBJDIR)/$($@_TARGET)/build -c riscv-gnu-toolchain expat | gzip > $(abspath $@)

$(OBJDIR)/%/stamps/riscv-gnu-toolchain/install.stamp: \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/build-gcc-newlib-stage2/stamp \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/build-gdb-py-newlib/stamp
	mkdir -p $(dir $@)
	date > $@

$(OBJDIR)/%/build/riscv-gnu-toolchain/stamp:
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/riscv-gnu-toolchain/stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/riscv-gnu-toolchain/stamp,%/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET),$@))
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	mkdir -p $($@_INSTALL)/python
	cd $(dir $@); curl -L -f -s -o python-3.7.7-$($@_TARGET).tar.gz https://github.com/sifive/freedom-tools-resources/releases/download/v0-test1/python-3.7.7-$($@_TARGET).tar.gz
	cd $($@_INSTALL)/python; $(TAR) -xf $(abspath $(dir $@))/python-3.7.7-$($@_TARGET).tar.gz
	cd $(dir $@); rm python-3.7.7-$($@_TARGET).tar.gz
	cp patches/pyconfig-centos6.sh $($@_INSTALL)/python
	cp patches/pyconfig-mingw32.sh $($@_INSTALL)/python
	cp -a $(SRC_RBU) $(SRC_RGCC) $(SRC_RGDB) $(SRC_RNL) $(dir $@)
	cd $(dir $@)/riscv-gcc; ./contrib/download_prerequisites
	cd $(dir $@)/riscv-gcc/gcc/config/riscv; rm t-elf-multilib; ./multilib-generator $(MULTILIBS_GEN) > t-elf-multilib
	$(SED) -E -i -f $(PATCHESDIR)/python-c-gdb.sed $(dir $@)/riscv-gdb/gdb/python/python.c
	date > $@

$(OBJDIR)/%/build/riscv-gnu-toolchain/build-binutils-newlib/stamp: \
		$(OBJDIR)/%/stamps/expat/install.stamp \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/riscv-gnu-toolchain/build-binutils-newlib/stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/riscv-gnu-toolchain/build-binutils-newlib/stamp,%/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET),$@))
	$(eval $@_BUILD := $(patsubst %/build/riscv-gnu-toolchain/build-binutils-newlib/stamp,%/build/riscv-gnu-toolchain,$@))
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
# CC_FOR_TARGET is required for the ld testsuite.
	cd $(dir $@) && CC_FOR_TARGET=$(NEWLIB_CC_FOR_TARGET) $(abspath $($@_BUILD))/riscv-binutils/configure \
		--target=$(NEWLIB_TUPLE) \
		$($($@_TARGET)-rgt-host) \
		--prefix=$(abspath $($@_INSTALL)) \
		--with-pkgversion="SiFive Binutils $(RGBU_VERSION)" \
		--with-bugurl="https://github.com/sifive/freedom-tools/issues" \
		--disable-werror \
		$(BINUTILS_TARGET_FLAGS) \
		$($($@_TARGET)-rgbu-configure) \
		--with-python=no \
		--disable-gdb \
		--disable-sim \
		--disable-libdecnumber \
		--disable-libreadline \
		CFLAGS="-O2" \
		CXXFLAGS="-O2" &>make-configure.log
	$(MAKE) -C $(dir $@) &>$(dir $@)/make-build.log
	$(MAKE) -C $(dir $@) -j1 install install-pdf install-html &>$(dir $@)/make-install.log
	date > $@

$(OBJDIR)/%/build/riscv-gnu-toolchain/build-gdb-newlib/stamp: \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/build-binutils-newlib/stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/riscv-gnu-toolchain/build-gdb-newlib/stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/riscv-gnu-toolchain/build-gdb-newlib/stamp,%/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET),$@))
	$(eval $@_BUILD := $(patsubst %/build/riscv-gnu-toolchain/build-gdb-newlib/stamp,%/build/riscv-gnu-toolchain,$@))
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
# CC_FOR_TARGET is required for the ld testsuite.
	cd $(dir $@) && CC_FOR_TARGET=$(NEWLIB_CC_FOR_TARGET) $(abspath $($@_BUILD))/riscv-gdb/configure \
		--target=$(NEWLIB_TUPLE) \
		$($($@_TARGET)-rgt-host) \
		--prefix=$(abspath $($@_INSTALL)) \
		--with-pkgversion="SiFive GDB $(RGDB_VERSION)" \
		--with-bugurl="https://github.com/sifive/freedom-tools/issues" \
		--disable-werror \
		$(GDB_TARGET_FLAGS) \
		$($($@_TARGET)-rgbu-configure) \
		--with-python=no \
		--with-lzma=no \
		--enable-gdb \
		--disable-gas \
		--disable-binutils \
		--disable-ld \
		--disable-gold \
		--disable-gprof \
		CFLAGS="-O2" \
		CXXFLAGS="-O2" &>make-configure.log
	$(MAKE) -C $(dir $@) &>$(dir $@)/make-build.log
	$(MAKE) -C $(dir $@) -j1 install install-pdf install-html &>$(dir $@)/make-install.log
	date > $@

$(OBJDIR)/%/build/riscv-gnu-toolchain/build-gdb-py-newlib/stamp: \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/build-gdb-newlib/stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/riscv-gnu-toolchain/build-gdb-py-newlib/stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/riscv-gnu-toolchain/build-gdb-py-newlib/stamp,%/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET),$@))
	$(eval $@_BUILD := $(patsubst %/build/riscv-gnu-toolchain/build-gdb-py-newlib/stamp,%/build/riscv-gnu-toolchain,$@))
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
# CC_FOR_TARGET is required for the ld testsuite.
	cd $(dir $@) && CC_FOR_TARGET=$(NEWLIB_CC_FOR_TARGET) $(abspath $($@_BUILD))/riscv-gdb/configure \
		--target=$(NEWLIB_TUPLE) \
		$($($@_TARGET)-rgt-host) \
		--prefix=$(abspath $($@_INSTALL)) \
		--with-pkgversion="SiFive GDB $(RGDB_VERSION)" \
		--with-bugurl="https://github.com/sifive/freedom-tools/issues" \
		--disable-werror \
		$(GDB_TARGET_FLAGS) \
		$($($@_TARGET)-rgbu-configure) \
		$($($@_TARGET)-rgdb-python) \
		--program-prefix="$(NEWLIB_TUPLE)-" \
		--program-suffix="-py" \
		--with-lzma=no \
		--enable-gdb \
		--disable-gas \
		--disable-binutils \
		--disable-ld \
		--disable-gold \
		--disable-gprof \
		CFLAGS="-O2" \
		CXXFLAGS="-O2" &>make-configure.log
	$(MAKE) -C $(dir $@) &>$(dir $@)/make-build.log
	$(MAKE) -C $(dir $@) -j1 install install-pdf install-html &>$(dir $@)/make-install.log
	date > $@

$(OBJDIR)/%/build/riscv-gnu-toolchain/build-gcc-newlib-stage1/stamp: \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/build-binutils-newlib/stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/riscv-gnu-toolchain/build-gcc-newlib-stage1/stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/riscv-gnu-toolchain/build-gcc-newlib-stage1/stamp,%/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET),$@))
	$(eval $@_BUILD := $(patsubst %/build/riscv-gnu-toolchain/build-gcc-newlib-stage1/stamp,%/build/riscv-gnu-toolchain,$@))
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	cd $(dir $@) && $(abspath $($@_BUILD))/riscv-gcc/configure \
		--target=$(NEWLIB_TUPLE) \
		$($($@_TARGET)-rgt-host) \
		--prefix=$(abspath $($@_INSTALL)) \
		--with-pkgversion="SiFive GCC $(RGT_VERSION)" \
		--with-bugurl="https://github.com/sifive/freedom-tools/issues" \
		--disable-shared \
		--disable-threads \
		--disable-tls \
		--enable-languages=c,c++ \
		--with-newlib \
		--with-sysroot=$(abspath $($@_INSTALL))/$(NEWLIB_TUPLE) \
		--disable-libmudflap \
		--disable-libssp \
		--disable-libquadmath \
		--disable-libgomp \
		--disable-nls \
		--disable-tm-clone-registry \
		--src=../riscv-gcc \
		$($($@_TARGET)-rgcc-configure) \
		--enable-checking=yes \
		--enable-multilib \
		--with-abi=$(WITH_ABI) \
		--with-arch=$(WITH_ARCH) \
		CFLAGS="-O2" \
		CXXFLAGS="-O2" \
		CFLAGS_FOR_TARGET="-Os $(CFLAGS_FOR_TARGET)" \
		CXXFLAGS_FOR_TARGET="-Os $(CXXFLAGS_FOR_TARGET)" &>make-configure.log
	$(MAKE) -C $(dir $@) all-gcc &>$(dir $@)/make-build.log
	$(MAKE) -C $(dir $@) -j1 install-gcc &>$(dir $@)/make-install.log
	date > $@

$(OBJDIR)/%/build/riscv-gnu-toolchain/build-newlib/stamp: \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/build-gcc-newlib-stage1/stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/riscv-gnu-toolchain/build-newlib/stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/riscv-gnu-toolchain/build-newlib/stamp,%/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET),$@))
	$(eval $@_BUILD := $(patsubst %/build/riscv-gnu-toolchain/build-newlib/stamp,%/build/riscv-gnu-toolchain,$@))
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	cd $(dir $@) && $(abspath $($@_BUILD))/riscv-newlib/configure \
		--target=$(NEWLIB_TUPLE) \
		$($($@_TARGET)-rgt-host) \
		--prefix=$(abspath $($@_INSTALL)) \
		--enable-newlib-io-long-double \
		--enable-newlib-io-long-long \
		--enable-newlib-io-c99-formats \
		--enable-newlib-register-fini \
		CFLAGS_FOR_TARGET="-O2 -D_POSIX_MODE $(CFLAGS_FOR_TARGET)" \
		CXXFLAGS_FOR_TARGET="-O2 -D_POSIX_MODE $(CXXFLAGS_FOR_TARGET)" &>make-configure.log
	$(MAKE) -C $(dir $@) &>$(dir $@)/make-build.log
	$(MAKE) -C $(dir $@) -j1 install &>$(dir $@)/make-install.log
# These install multiple copies of the same docs into the same destination
# for a multilib build.  So we must not parallelize them.
# TODO: Rewrite so that we only install one copy of the docs.
	$(MAKE) -j1 -C $(dir $@) install-pdf install-html &>$(dir $@)/make-install-doc.log
	date > $@

$(OBJDIR)/%/build/riscv-gnu-toolchain/build-newlib-nano/stamp: \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/build-gcc-newlib-stage1/stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/riscv-gnu-toolchain/build-newlib-nano/stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/riscv-gnu-toolchain/build-newlib-nano/stamp,%/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET),$@))
	$(eval $@_BUILD := $(patsubst %/build/riscv-gnu-toolchain/build-newlib-nano/stamp,%/build/riscv-gnu-toolchain,$@))
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	cd $(dir $@) && $(abspath $($@_BUILD))/riscv-newlib/configure \
		--target=$(NEWLIB_TUPLE) \
		$($($@_TARGET)-rgt-host) \
		--prefix=$(abspath $($@_BUILD)/build-newlib-nano-install) \
		--enable-newlib-reent-small \
		--disable-newlib-fvwrite-in-streamio \
		--disable-newlib-fseek-optimization \
		--disable-newlib-wide-orient \
		--enable-newlib-nano-malloc \
		--disable-newlib-unbuf-stream-opt \
		--enable-lite-exit \
		--enable-newlib-global-atexit \
		--enable-newlib-nano-formatted-io \
		--disable-newlib-supplied-syscalls \
		--disable-nls \
		CFLAGS_FOR_TARGET="-Os -ffunction-sections -fdata-sections $(CFLAGS_FOR_TARGET)" \
		CXXFLAGS_FOR_TARGET="-Os -ffunction-sections -fdata-sections $(CXXFLAGS_FOR_TARGET)" &>make-configure.log
	$(MAKE) -C $(dir $@) &>$(dir $@)/make-build.log
	$(MAKE) -C $(dir $@) -j1 install &>$(dir $@)/make-install.log
	date > $@

$(OBJDIR)/%/build/riscv-gnu-toolchain/build-newlib-nano-install/stamp: \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/build-newlib-nano/stamp \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/build-newlib/stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/riscv-gnu-toolchain/build-newlib-nano-install/stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/riscv-gnu-toolchain/build-newlib-nano-install/stamp,%/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET),$@))
	$(eval $@_BUILD := $(patsubst %/build/riscv-gnu-toolchain/build-newlib-nano-install/stamp,%/build/riscv-gnu-toolchain,$@))
# Copy nano library files into newlib install dir.
	set -e; \
	bnl="$(abspath $($@_BUILD))/build-newlib-nano-install/$(NEWLIB_TUPLE)/lib"; \
	inl="$(abspath $($@_INSTALL))/$(NEWLIB_TUPLE)/lib"; \
	for bnlc in `find $${bnl} -name libc.a`; \
	do \
		inlc=`echo $${bnlc} | $(SED) -e "s:$${bnl}::" | $(SED) -e "s:libc\.a:libc_nano.a:g"`; \
		cp $${bnlc} $${inl}$${inlc}; \
	done; \
	for bnlm in `find $${bnl} -name libm.a`; \
	do \
		inlm=`echo $${bnlm} | $(SED) -e "s:$${bnl}::" | $(SED) -e "s:libm\.a:libm_nano.a:g"`; \
		cp $${bnlm} $${inl}$${inlm}; \
	done; \
	for bnlg in `find $${bnl} -name libg.a`; \
	do \
		inlg=`echo $${bnlg} | $(SED) -e "s:$${bnl}::" | $(SED) -e "s:libg\.a:libg_nano.a:g"`; \
		cp $${bnlg} $${inl}$${inlg}; \
	done; \
	for bnls in `find $${bnl} -name libgloss.a`; \
	do \
		inls=`echo $${bnls} | $(SED) -e "s:$${bnl}::" | $(SED) -e "s:libgloss\.a:libgloss_nano.a:g"`; \
		cp $${bnls} $${inl}$${inls}; \
	done; \
	for bnls in `find $${bnl} -name crt0.o`; \
	do \
		inls=`echo $${bnls} | $(SED) -e "s:$${bnl}::"`; \
		cp $${bnls} $${inl}$${inls}; \
	done
# Copy nano header files into newlib install dir.
	mkdir -p $(abspath $($@_INSTALL))/$(NEWLIB_TUPLE)/include/newlib-nano; \
	cp $(abspath $($@_BUILD))/build-newlib-nano-install/$(NEWLIB_TUPLE)/include/newlib.h \
		$(abspath $($@_INSTALL))/$(NEWLIB_TUPLE)/include/newlib-nano/newlib.h; \
	date > $@

$(OBJDIR)/%/build/riscv-gnu-toolchain/build-gcc-newlib-stage2/stamp: \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/build-newlib/stamp \
		$(OBJDIR)/%/build/riscv-gnu-toolchain/build-newlib-nano-install/stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/riscv-gnu-toolchain/build-gcc-newlib-stage2/stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/riscv-gnu-toolchain/build-gcc-newlib-stage2/stamp,%/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET),$@))
	$(eval $@_BUILD := $(patsubst %/build/riscv-gnu-toolchain/build-gcc-newlib-stage2/stamp,%/build/riscv-gnu-toolchain,$@))
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	cd $(dir $@) && $(abspath $($@_BUILD))/riscv-gcc/configure \
		--target=$(NEWLIB_TUPLE) \
		$($($@_TARGET)-rgt-host) \
		--prefix=$(abspath $($@_INSTALL)) \
		--with-pkgversion="SiFive GCC $(RGT_VERSION)" \
		--with-bugurl="https://github.com/sifive/freedom-tools/issues" \
		--disable-shared \
		--disable-threads \
		--enable-languages=c,c++ \
		--enable-tls \
		--with-newlib \
		--with-sysroot=$(abspath $($@_INSTALL))/$(NEWLIB_TUPLE) \
		--with-native-system-header-dir=/include \
		--disable-libmudflap \
		--disable-libssp \
		--disable-libquadmath \
		--disable-libgomp \
		--disable-nls \
		--disable-tm-clone-registry \
		--src=../riscv-gcc \
		$($($@_TARGET)-rgcc-configure) \
		--enable-checking=yes \
		--enable-multilib \
		--with-abi=$(WITH_ABI) \
		--with-arch=$(WITH_ARCH) \
		CFLAGS="-O2" \
		CXXFLAGS="-O2" \
		CFLAGS_FOR_TARGET="-Os $(CFLAGS_FOR_TARGET)" \
		CXXFLAGS_FOR_TARGET="-Os $(CXXFLAGS_FOR_TARGET)" &>make-configure.log
	$(MAKE) -C $(dir $@) &>$(dir $@)/make-build.log
	$(MAKE) -C $(dir $@) -j1 install install-pdf install-html &>$(dir $@)/make-install.log
	date > $@

# The Windows build requires the native toolchain.  The dependency is enforced
# here, PATH allows the tools to get access.
$(OBJ_WIN64)/stamps/riscv-gnu-toolchain/install.stamp: \
	$(OBJ_NATIVE)/stamps/riscv-gnu-toolchain/install.stamp

$(OBJ_WIN32)/stamps/riscv-gnu-toolchain/install.stamp: \
	$(OBJ_NATIVE)/stamps/riscv-gnu-toolchain/install.stamp

# OpenOCD requires a GDB that's been build with expat support so it can read
# the target XML files.
$(OBJDIR)/%/stamps/expat/install.stamp: \
		$(OBJDIR)/%/build/expat/configure
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/stamps/expat/install.stamp,%,$@))
	$(eval $@_BUILD := $(patsubst %/stamps/expat/install.stamp,%/build/expat,$@))
	$(eval $@_INSTALL := $(patsubst %/stamps/expat/install.stamp,%/install/riscv64-unknown-elf-gcc-$(RGT_VERSION)-$($@_TARGET),$@))
	mkdir -p $($@_BUILD)
	cd $($@_BUILD); ./configure --prefix=$(abspath $($@_INSTALL)) $($($@_TARGET)-expat-configure) &>make-configure.log
	$(MAKE) -C $($@_BUILD) buildlib &>$($@_BUILD)/make-buildlib.log
	$(MAKE) -C $($@_BUILD) -j1 installlib &>$($@_BUILD)/make-installlib.log
	rm -f $(abspath $($@_INSTALL))/lib/libexpat*.dylib*
	rm -f $(abspath $($@_INSTALL))/lib/libexpat*.so*
	rm -f $(abspath $($@_INSTALL))/lib64/libexpat*.so*
	mkdir -p $(dir $@)
	date > $@

$(OBJDIR)/%/build/expat/configure:
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	cp -a $(SRC_EXPAT)/* $(dir $@)
	mkdir -p $(dir $@)/m4
	cd $(dir $@); ./buildconf.sh &>make-buildconf.log
	touch -c $@


# Targets that don't build anything
.PHONY: clean
clean::
	rm -rf $(OBJDIR) $(BINDIR)
