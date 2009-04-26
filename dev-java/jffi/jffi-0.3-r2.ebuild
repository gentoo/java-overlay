# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# Probably best to leave the CFLAGS as they are here. See...
# http://weblogs.java.net/blog/kellyohair/archive/2006/01/compilation_of_1.html

EAPI="2"
JAVA_PKG_IUSE="source test"
inherit base java-vm-2 java-pkg-2 java-ant-2 toolchain-funcs

DESCRIPTION="An optimized Java interface to libffi"
HOMEPAGE="http://kenai.com/projects/jffi"
SRC_URI="http://dev.gentooexperimental.org/~chewi/distfiles/${P}.tbz2"
LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.5
	>=sys-devel/gcc-4.3[libffi]"

DEPEND=">=virtual/jdk-1.5
	>=sys-devel/gcc-4.3[libffi]
	test? ( dev-java/ant-junit4 )"

pkg_setup() {
	if (( `gcc-major-version` < 4 )) || (( `gcc-minor-version` < 3 )) ; then
		eerror "gcc 4.3 or greater is needed to build and run this. You seem to have a"
		eerror "sufficient version installed but you need to select it with gcc-config."
		die "gcc 4.3 or greater must be selected"
	fi
}

JAVA_PKG_BSFIX_NAME="build-impl.xml"

java_prepare() {
	# Delete the bundled JARs.
	find lib -name "*.jar" -delete || die

	# Fetch our own prebuilt libffi.
	mkdir -p "build/jni/libffi-$(get_system_arch)-linux/.libs" || die
	ln -snf "${ROOT}`_gcc-install-dir`/libffi.so" "build/jni/libffi-$(get_system_arch)-linux/.libs/libffi_convenience.a" || die

	# Don't include prebuilt files for other archs.
	sed -i '/<zipfileset src="archive\//d' custom-build.xml || die
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	use source && java-pkg_dosrc src/*
}

src_test() {
	ANT_TASKS="ant-junit4" eant test -Dlibs.junit_4.classpath="$(java-pkg_getjars --with-dependencies junit-4)"
}
