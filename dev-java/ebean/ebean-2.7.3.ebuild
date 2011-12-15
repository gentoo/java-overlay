# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
JAVA_PKG_IUSE="doc source"
JAVA_PKG_WANT_BOOTCLASSPATH="1.5"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="An ORM for Java from Avaje"
HOMEPAGE="http://www.avaje.org/"
SRC_URI="mirror://sourceforge/ebeanorm/${P}.zip"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="scala"

CDEPEND="dev-java/ant-core:0
	dev-java/glassfish-persistence:0
	dev-java/glassfish-transaction-api:0
	dev-java/joda-time:0
	dev-java/lucene:3.0
	java-virtuals/servlet-api:2.5
	scala? ( dev-lang/scala:0 )"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"

DEPEND="${CDEPEND}
	app-arch/unzip
	>=virtual/jdk-1.5"

S="${WORKDIR}/${P}"
JAVA_GENTOO_CLASSPATH="ant-core glassfish-persistence glassfish-transaction-api joda-time lucene-3.0 servlet-api-2.5"
NON_GNU="com/avaje/ebeaninternal/server/el/ElFilter"

pkg_setup() {
	java-pkg-2_pkg_setup
	use scala && JAVA_GENTOO_CLASSPATH="${JAVA_GENTOO_CLASSPATH} scala"
}

java_prepare() {
	unpack "./${P}-sources.jar"
	cp -v "${NON_GNU}.java"{,.orig} || die

	if ! use scala; then
		einfo "Removing Scala support ..."
		find -regex ".*/[^/]*Scala[^r][^/]*\.java" -exec rm -vf {} \; || die
		epatch "${FILESDIR}/no-scala.patch"
	fi
}

src_compile() {
	# GNU Classpath 0.98 doesn't support Pattern.quote.
	sed -i "s/Pattern\.quote//g" "${NON_GNU}.java" || die

	# Build with GNU Classpath.
	JAVAC_ARGS="-Xbootclasspath/p:$(java-pkg_get-bootclasspath 1.5)" java-pkg-simple_src_compile

	# Restore Pattern.quote and rebuild the class that uses it.
	cp -v "${NON_GNU}.java"{.orig,} || die
	ejavac -cp target/classes -d target/classes "${NON_GNU}.java"
	jar uf "${PN}.jar" -C target/classes "${NON_GNU}.class" || die
}

src_install() {
	java-pkg-simple_src_install
	java-pkg_register-optional-dependency jdbc-mysql,jdbc-postgresql,sqlite-jdbc,h2
	dodoc readme.txt || die
	newdoc "${PN}"-userguide{-*,}.pdf || die
}
