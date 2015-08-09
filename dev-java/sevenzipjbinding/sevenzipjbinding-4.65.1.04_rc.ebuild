# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"

inherit eutils versionator flag-o-matic java-pkg-2 java-pkg-simple cmake-utils

MY_PN="sevenzipjbind"
P7Z_PV="$(get_version_component_range 1-2)"
MY_PV="$(replace_version_separator 2 '-')"
MY_P="${PN}-${MY_PV//_/-}-extr-only-Linux-amd64" # No pure source tarballs.

GITWEB="http://${MY_PN}.git.sourceforge.net/git/gitweb.cgi"
MAIN_COMMIT="Release-${MY_PV//_/}-extr-only"
TEST_COMMIT="a2bef9f"

DESCRIPTION="A Java wrapper around the native 7-Zip library"
HOMEPAGE="http://${MY_PN}.sourceforge.net"
SRC_URI="mirror://sourceforge/${MY_PN}/7-Zip-JBinding/${MY_PV//_/}-extr-only/${MY_P}.zip
	mirror://sourceforge/p7zip/p7zip_${P7Z_PV}_src_all.tar.bz2
	${GITWEB}?p=${MY_PN}/${MY_PN};a=blob_plain;f=jbinding-cpp/CMakeLists.txt;hb=${MAIN_COMMIT} -> ${P}-CMakeLists.txt
	test? ( ${GITWEB}?p=${MY_PN}/${MY_PN};a=snapshot;h=${TEST_COMMIT};sf=tgz -> ${P}-tests.tar.gz )"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

RDEPEND=">=virtual/jre-1.5"

DEPEND=">=virtual/jdk-1.5
	test? ( dev-java/junit:4 )"

S="${WORKDIR}/${MY_P}"
JAVA_SRC_DIR="jbinding-java"
CMAKE_USE_DIR="${S}/jbinding-cpp"

# These are set in the parent CMakeLists.txt, which we don't use.
mycmakeargs=( "-DJAVA_HEADER_COMPILE=javah" "-DSEVENZIP_JBINDING_JAR='${S}/${PN}.jar'" )

src_prepare() {
	# Symlink to the tests as they are upstream.
	ln -snf "../${MY_PN}-${TEST_COMMIT}" "${S}/tests" || die

	# Ensure the prebuilt binaries aren't used.
	rm -rf "${S}/lib" "${S}/tests/JavaTests/lib" || die

	# This is where the build expects to find p7zip.
	ln -snf "../p7zip_${P7Z_PV}" "${S}/p7zip" || die

	# Apply the p7zip fixes.
	cd "${S}/p7zip" || die
	epatch "${FILESDIR}/p7zip-fixes.patch"

	# Unpack the sources.
	local X; for X in java cpp; do
		mkdir "${S}/jbinding-${X}" || die
		cd "${S}/jbinding-${X}" || die
		unpack "./../${X}-src.zip"
	done

	# Patch to load native library from library path.
	cd "${S}/jbinding-java" || die
	epatch "${FILESDIR}/native-lib-load.patch"

	# This is only available via git. Why!?
	cp "${DISTDIR}/${P}-CMakeLists.txt" "${S}/jbinding-cpp/CMakeLists.txt" || die
}

src_configure() {
	append-cppflags $(java-pkg_get-jni-cflags)
	cmake-utils_src_configure
}

src_compile() {
	java-pkg-simple_src_compile
	cmake-utils_src_compile
}

src_install() {
	java-pkg-simple_src_install
	java-pkg_doso "${CMAKE_BUILD_DIR}/lib7-Zip-JBinding.so"
	dodoc AUTHORS ChangeLog NEWS README ReleaseNotes.txt THANKS || die
}

src_test() {
	cd tests/JavaTests || die
	local CP="src:${S}/${PN}.jar:$(java-pkg_getjars --with-dependencies junit-4)"
	ejavac -classpath "${CP}" -d src $(find src -name "*.java")
	java -classpath "${CP}" -Djava.library.path="${CMAKE_BUILD_DIR}" \
		org.junit.runner.JUnitCore net.sf.sevenzipjbinding.junit.AllTestSuite || die
}
