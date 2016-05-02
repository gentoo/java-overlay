# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

MY_PV="2014-04-05"
JAVA_PKG_IUSE="doc"

inherit eutils java-pkg-2 java-pkg-simple

DESCRIPTION="Java SQL Database"
HOMEPAGE="http://www.h2database.com/"
SRC_URI="http://www.h2database.com/${PN}-${MY_PV}.zip"
LICENSE="EPL-1.0 H2-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# The tests are highly explosive, even using upstream's scripts, and
# take ages to run. They seem to require quite a particular environment.
RESTRICT="test"

CDEPEND="dev-java/jts-core:0
	dev-java/lucene:3.6
	dev-java/osgi-core-api:0
	dev-java/osgi-enterprise-api:0
	dev-java/slf4j-api:0
	java-virtuals/servlet-api:2.4"

DEPEND="${CDEPEND}
	app-arch/unzip
	app-arch/zip
	>=virtual/jdk-1.7"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.7"

S="${WORKDIR}/${PN}"
JAVA_SRC_DIR="src/main src/tools/org/h2/dev src/tools/org/h2/jaqu src/tools/org/h2/mode"
JAVA_GENTOO_CLASSPATH="jts-core,lucene-3.6,osgi-core-api,osgi-enterprise-api,servlet-api-2.4,slf4j-api"

java_prepare() {
	# Compatibility with OSGi 5.
	epatch "${FILESDIR}/osgi-5.patch"

	# Uncomment the Java 7 methods as we are at least targeting that.
	find -name "*.java" -exec sed -i "/\/\*## Java 1\.7 ##/s:/*://:" {} + || die

	# Extract metadata from the binary.
	mkdir -p target/classes || die
	cd target/classes || die
	jar xf "${S}/bin/${PN}"-*.jar META-INF || die
}

src_compile() {
	java-pkg-simple_src_compile

	# See src/tools/org/h2/build/Build.java.
	local DATA="org/h2/util/data.zip"
	cd src/main || die
	rm -f "${DATA}" || die
	zip "${DATA}" $(find -type f ! -name "*.MF" ! -name "*.java" ! -name "package.html" ! -name "java.sql.Driver") || die
	jar uf "${S}/${PN}.jar" "${DATA}" || die
}

src_install() {
	java-pkg-simple_src_install
	java-pkg_dolauncher "${PN}" --main org.h2.tools.Console
	java-pkg_register-optional-dependency hsqldb,jdbc-jaybird,jdbc-mssqlserver-4.0,jdbc-mysql,jdbc-postgresql

	if use doc; then
		dodoc "docs/${PN}.pdf"
		docinto html
		dodoc -r docs/index.html docs/html
		ln -snf "api" "${D}/usr/share/doc/${PF}/html/javadoc" || die
		ln -snf "../${PN}.pdf" "${D}/usr/share/doc/${PF}/html/" || die
	fi
}

src_test() {
	local CP=$(java-config -t):$(java-config -d -p "${JAVA_GENTOO_CLASSPATH}"):"${S}/${PN}.jar"

	cd src/test || die
	ejavac -classpath "${CP}" $(find -name "*.java")
	java -classpath "${CP}:." org.h2.test.TestAll all || die
}
