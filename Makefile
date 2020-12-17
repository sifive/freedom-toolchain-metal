# Setup the Freedom build script environment
include scripts/Freedom.mk

# Include version identifiers to build up the full version string
include Version.mk
PACKAGE_WORDING := Bare Metal Toolchain
PACKAGE_HEADING := riscv64-unknown-elf-toolchain
PACKAGE_VERSION := $(RISCV_TOOLCHAIN_METAL_VERSION)-$(FREEDOM_TOOLCHAIN_METAL_ID)$(EXTRA_SUFFIX)

# Source code directory references
BARE_METAL_TUPLE := riscv64-unknown-elf
BARE_METAL_CC_FOR_TARGET ?= $(BARE_METAL_TUPLE)-gcc
BARE_METAL_CXX_FOR_TARGET ?= $(BARE_METAL_TUPLE)-g++

# Some special package references for specific targets
NATIVE_BINUTILS_TARBALL = $(wildcard $(BINDIR)/riscv64-unknown-elf-binutils-*-$(NATIVE).tar.gz)
NATIVE_GCC_TARBALL = $(wildcard $(BINDIR)/riscv64-unknown-elf-gcc-*-$(NATIVE).tar.gz)
NATIVE_GDB_TARBALL = $(wildcard $(BINDIR)/riscv64-unknown-elf-gdb-*-$(NATIVE).tar.gz)
WIN64_BINUTILS_TARBALL = $(wildcard $(BINDIR)/riscv64-unknown-elf-binutils-*-$(WIN64).tar.gz)
WIN64_GCC_TARBALL = $(wildcard $(BINDIR)/riscv64-unknown-elf-gcc-*-$(WIN64).tar.gz)
WIN64_GDB_TARBALL = $(wildcard $(BINDIR)/riscv64-unknown-elf-gdb-*-$(WIN64).tar.gz)

# Setup the package targets and switch into secondary makefile targets
# Targets $(PACKAGE_HEADING)/install.stamp and $(PACKAGE_HEADING)/libs.stamp
include scripts/Package.mk

$(OBJDIR)/%/build/$(PACKAGE_HEADING)/install.stamp: \
		$(OBJDIR)/%/build/$(PACKAGE_HEADING)/build-gdb/build.stamp
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/$(PACKAGE_HEADING)/install.stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/$(PACKAGE_HEADING)/install.stamp,%/install/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$($@_TARGET),$@))
	$(eval $@_REC := $(abspath $(patsubst %/build/$(PACKAGE_HEADING)/install.stamp,%/rec/$(PACKAGE_HEADING),$@)))
	mkdir -p $(dir $@)
	mkdir -p $(dir $@)/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$($@_TARGET).bundle/features
	git log --format="[%ad] %s" > $(abspath $($@_INSTALL))/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$($@_TARGET).changelog
	cp README.md $(abspath $($@_INSTALL))/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$($@_TARGET).readme.md
	tclsh scripts/generate-feature-xml.tcl "$(PACKAGE_WORDING)" "$(PACKAGE_HEADING)" "$(RISCV_TOOLCHAIN_METAL_VERSION)" "$(FREEDOM_TOOLCHAIN_METAL_ID)" $($@_TARGET) $(abspath $($@_INSTALL))
	tclsh scripts/generate-chmod755-sh.tcl $(abspath $($@_INSTALL))
	tclsh scripts/generate-site-xml.tcl "$(PACKAGE_WORDING)" "$(PACKAGE_HEADING)" "$(RISCV_TOOLCHAIN_METAL_VERSION)" "$(FREEDOM_TOOLCHAIN_METAL_ID)" $($@_TARGET) $(abspath $(dir $@))/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$($@_TARGET).bundle
	tclsh scripts/extract-all-bundle-mk.tcl $(abspath $($@_INSTALL)) "RISCV_TAGS TOOLS_TAGS" $(wildcard $($@_REC)/bundle-*.mk)
	cp $(abspath $($@_INSTALL))/bundle.mk $(abspath $(dir $@))/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$($@_TARGET).bundle
	cd $($@_INSTALL); zip -rq $(abspath $(dir $@))/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$($@_TARGET).bundle/features/$(PACKAGE_HEADING)_$(FREEDOM_TOOLCHAIN_METAL_ID)_$(RISCV_TOOLCHAIN_METAL_VERSION).jar *
	tclsh scripts/check-maximum-path-length.tcl $(abspath $($@_INSTALL)) "$(PACKAGE_HEADING)" "$(RISCV_TOOLCHAIN_METAL_VERSION)" "$(FREEDOM_TOOLCHAIN_METAL_ID)"
	tclsh scripts/check-same-name-different-case.tcl $(abspath $($@_INSTALL))
	date > $@

# We might need some extra target libraries for this package
$(OBJ_NATIVE)/build/$(PACKAGE_HEADING)/libs.stamp: \
		$(OBJ_NATIVE)/build/$(PACKAGE_HEADING)/install.stamp
	date > $@

$(OBJ_WIN64)/build/$(PACKAGE_HEADING)/libs.stamp: \
		$(OBJ_WIN64)/build/$(PACKAGE_HEADING)/install.stamp
	date > $@

$(OBJDIR)/%/build/$(PACKAGE_HEADING)/source.stamp:
	$(eval $@_TARGET := $(patsubst $(OBJDIR)/%/build/$(PACKAGE_HEADING)/source.stamp,%,$@))
	$(eval $@_INSTALL := $(patsubst %/build/$(PACKAGE_HEADING)/source.stamp,%/install/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$($@_TARGET),$@))
	$(eval $@_REC := $(abspath $(patsubst %/build/$(PACKAGE_HEADING)/source.stamp,%/rec/$(PACKAGE_HEADING),$@)))
	tclsh scripts/check-naming-and-version-syntax.tcl "$(PACKAGE_WORDING)" "$(PACKAGE_HEADING)" "$(RISCV_TOOLCHAIN_METAL_VERSION)" "$(FREEDOM_TOOLCHAIN_METAL_ID)"
	rm -rf $($@_INSTALL)
	mkdir -p $($@_INSTALL)
	rm -rf $($@_REC)
	mkdir -p $($@_REC)
	rm -rf $(dir $@)
	mkdir -p $(dir $@)
	git log > $($@_REC)/$(PACKAGE_HEADING)-git-commit.log
#	cp .gitmodules $($@_REC)/$(PACKAGE_HEADING)-git-modules.log
	git remote -v > $($@_REC)/$(PACKAGE_HEADING)-git-remote.log
#	git submodule status > $($@_REC)/$(PACKAGE_HEADING)-git-submodule.log
	date > $@

$(OBJ_NATIVE)/build/$(PACKAGE_HEADING)/build-binutils/build.stamp: \
		$(OBJ_NATIVE)/build/$(PACKAGE_HEADING)/source.stamp
ifneq ($(NATIVE_BINUTILS_TARBALL),)
	$(eval $@_TARNAME = $(basename $(basename $(notdir $(NATIVE_BINUTILS_TARBALL)))))
	mkdir -p $(OBJ_NATIVE)/install/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$(NATIVE)
	rm -rf $(OBJ_NATIVE)/install/$($@_TARNAME)
	$(TAR) -xz -C $(OBJ_NATIVE)/install -f $(NATIVE_BINUTILS_TARBALL)
	cp $(OBJ_NATIVE)/install/$($@_TARNAME)/bundle.mk $(OBJ_NATIVE)/rec/$(PACKAGE_HEADING)/bundle-$($@_TARNAME).mk
	cp $(OBJ_NATIVE)/install/$($@_TARNAME)/chmod755.sh $(OBJ_NATIVE)/rec/$(PACKAGE_HEADING)/chmod755-$($@_TARNAME).sh
	cp $(OBJ_NATIVE)/install/$($@_TARNAME)/feature.xml $(OBJ_NATIVE)/rec/$(PACKAGE_HEADING)/feature-$($@_TARNAME).xml
	rm -f $(OBJ_NATIVE)/install/$($@_TARNAME)/bundle.mk
	rm -f $(OBJ_NATIVE)/install/$($@_TARNAME)/chmod755.sh
	rm -f $(OBJ_NATIVE)/install/$($@_TARNAME)/feature.xml
	cp -RL $(OBJ_NATIVE)/install/$($@_TARNAME)/* $(OBJ_NATIVE)/install/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$(NATIVE)/
endif
	mkdir -p $(dir $@)
	date > $@

$(OBJ_NATIVE)/build/$(PACKAGE_HEADING)/build-gcc/build.stamp: \
		$(OBJ_NATIVE)/build/$(PACKAGE_HEADING)/build-binutils/build.stamp
ifneq ($(NATIVE_GCC_TARBALL),)
	$(eval $@_TARNAME = $(basename $(basename $(notdir $(NATIVE_GCC_TARBALL)))))
	mkdir -p $(OBJ_NATIVE)/install/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$(NATIVE)
	rm -rf $(OBJ_NATIVE)/install/$($@_TARNAME)
	$(TAR) -xz -C $(OBJ_NATIVE)/install -f $(NATIVE_GCC_TARBALL)
	cp $(OBJ_NATIVE)/install/$($@_TARNAME)/bundle.mk $(OBJ_NATIVE)/rec/$(PACKAGE_HEADING)/bundle-$($@_TARNAME).mk
	cp $(OBJ_NATIVE)/install/$($@_TARNAME)/chmod755.sh $(OBJ_NATIVE)/rec/$(PACKAGE_HEADING)/chmod755-$($@_TARNAME).sh
	cp $(OBJ_NATIVE)/install/$($@_TARNAME)/feature.xml $(OBJ_NATIVE)/rec/$(PACKAGE_HEADING)/feature-$($@_TARNAME).xml
	rm -f $(OBJ_NATIVE)/install/$($@_TARNAME)/bundle.mk
	rm -f $(OBJ_NATIVE)/install/$($@_TARNAME)/chmod755.sh
	rm -f $(OBJ_NATIVE)/install/$($@_TARNAME)/feature.xml
	cp -RL $(OBJ_NATIVE)/install/$($@_TARNAME)/* $(OBJ_NATIVE)/install/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$(NATIVE)/
endif
	mkdir -p $(dir $@)
	date > $@

$(OBJ_NATIVE)/build/$(PACKAGE_HEADING)/build-gdb/build.stamp: \
		$(OBJ_NATIVE)/build/$(PACKAGE_HEADING)/build-gcc/build.stamp
ifneq ($(NATIVE_GDB_TARBALL),)
	$(eval $@_TARNAME = $(basename $(basename $(notdir $(NATIVE_GDB_TARBALL)))))
	mkdir -p $(OBJ_NATIVE)/install/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$(NATIVE)
	rm -rf $(OBJ_NATIVE)/install/$($@_TARNAME)
	$(TAR) -xz -C $(OBJ_NATIVE)/install -f $(NATIVE_GDB_TARBALL)
	cp $(OBJ_NATIVE)/install/$($@_TARNAME)/bundle.mk $(OBJ_NATIVE)/rec/$(PACKAGE_HEADING)/bundle-$($@_TARNAME).mk
	cp $(OBJ_NATIVE)/install/$($@_TARNAME)/chmod755.sh $(OBJ_NATIVE)/rec/$(PACKAGE_HEADING)/chmod755-$($@_TARNAME).sh
	cp $(OBJ_NATIVE)/install/$($@_TARNAME)/feature.xml $(OBJ_NATIVE)/rec/$(PACKAGE_HEADING)/feature-$($@_TARNAME).xml
	rm -f $(OBJ_NATIVE)/install/$($@_TARNAME)/bundle.mk
	rm -f $(OBJ_NATIVE)/install/$($@_TARNAME)/chmod755.sh
	rm -f $(OBJ_NATIVE)/install/$($@_TARNAME)/feature.xml
	cp -RL $(OBJ_NATIVE)/install/$($@_TARNAME)/* $(OBJ_NATIVE)/install/$(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$(NATIVE)/
endif
	mkdir -p $(dir $@)
	date > $@

$(OBJDIR)/$(NATIVE)/test/$(PACKAGE_HEADING)/test.stamp: \
		$(OBJDIR)/$(NATIVE)/test/$(PACKAGE_HEADING)/launch.stamp
	mkdir -p $(dir $@)
	@echo "Finished testing $(PACKAGE_HEADING)-$(PACKAGE_VERSION)-$(NATIVE).tar.gz tarball"
	date > $@
