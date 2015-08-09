# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="4"
MY_PV="2011-10-28"

JAVA_PKG_IUSE="doc"
JAVA_PKG_WANT_BOOTCLASSPATH="1.5"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="Java SQL Database"
HOMEPAGE="http://www.h2database.com/"
SRC_URI="http://www.h2database.com/${PN}-${MY_PV}.zip"
LICENSE="EPL-1.0 H2-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# Some tests fail even outside of Portage using upstream's own
# scripts. The failures we get here appear to be the same.
RESTRICT="test"

CDEPEND="dev-java/lucene:3.0
	dev-java/slf4j-api:0
	dev-java/tomcat-servlet-api:2.4"

DEPEND="${CDEPEND}
	app-arch/unzip
	app-arch/zip
	>=virtual/jdk-1.6"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.6"

S="${WORKDIR}/${PN}"
JAVA_SRC_DIR="src/main src/tools/org/h2/dev src/tools/org/h2/jaqu src/tools/org/h2/mode"
JAVA_GENTOO_CLASSPATH="lucene-3.0,slf4j-api,tomcat-servlet-api-2.4"

java_prepare() {
	if use test; then
		# This test uses way too much RAM and dies? But isn't that the point?
		sed -i "/TestOutOfMemory/d" "src/test/org/h2/test/TestAll.java" || die
	fi

	# Avoid the OSGi Framework stuff.
	rm -v "src/main/org/h2/util/DbDriverActivator.java" || die

	# Extract metadata from the binary.
	mkdir -p target/classes || die
	cd target/classes || die
	jar xf "${S}/bin/${PN}"-*.jar META-INF || die
}

src_compile() {
	JAVAC_ARGS="-Xbootclasspath/p:$(java-pkg_get-bootclasspath 1.5)" java-pkg-simple_src_compile

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
	java-pkg_register-optional-dependency hsqldb,jdbc-jaybird,jdbc-mssqlserver,jdbc-mssqlserver-2005,jdbc-mysql,jdbc-postgresql

	if use doc; then
		dodoc "docs/${PN}.pdf"
		dohtml -r docs/index.html docs/html
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
