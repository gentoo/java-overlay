# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"

JAVA_PKG_IUSE="doc source"
JAVA_PKG_WANT_BOOTCLASSPATH="1.5"

inherit eutils toolchain-funcs java-pkg-2 java-pkg-simple

DESCRIPTION="SQLite JDBC driver from the Xerial project"
HOMEPAGE="http://www.xerial.org/trac/Xerial/wiki/SQLiteJDBC"
SRC_URI="http://www.xerial.org/maven/repository/artifact/org/xerial/${PN}/${PV}/${P}-sources.jar"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.6
	dev-db/sqlite:3"

RDEPEND=">=virtual/jre-1.6
	dev-db/sqlite:3"

S="${WORKDIR}"
SONAME="libsqlitejdbc.so"

java_prepare() {
	# Allow the native library to be loaded from the path.
	epatch "${FILESDIR}/sqlite-jdbc-loadLibrary.patch"

	# Delete pure Java stuff.
	rm -rv org/ibex org/sqlite/NestedDB.* || die

	# Delete binaries.
	rm -rv native || die
	find -name "*.class" -exec rm -v {} \;
}

src_compile() {
	JAVAC_ARGS="-Xbootclasspath/p:$(java-pkg_get-bootclasspath 1.5)" java-pkg-simple_src_compile

	javah -classpath target/classes -jni -o NativeDB.h org.sqlite.NativeDB || die
	$(tc-getCC) $(java-pkg_get-jni-cflags) ${CFLAGS} ${LDFLAGS} \
		-I. -fPIC -shared -Wl,-z -Wl,defs -Wl,-soname="${SONAME}" \
		-o "${SONAME}" org/sqlite/NativeDB.c -lsqlite3 || die
}

src_install() {
	java-pkg-simple_src_install
	java-pkg_doso "${SONAME}"
}
