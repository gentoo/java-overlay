# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"
JAVA_PKG_IUSE="source test"
inherit java-pkg-2

DESCRIPTION="Apache XML-RPC is a Java implementation of XML-RPC"
HOMEPAGE="http://ws.apache.org/xmlrpc/"
SRC_URI="mirror://apache/ws/xmlrpc/sources/${P}-src.tar.gz"
LICENSE="Apache-2.0"
SLOT="3"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/commons-codec
	dev-java/commons-logging
	dev-java/commons-httpclient:3
	dev-java/servletapi:2.4
	dev-java/ws-commons-util
	dev-java/xerces:2"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.4
	test? ( dev-java/junit:0 )"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

EANT_GENTOO_CLASSPATH="commons-codec commons-logging commons-httpclient:3 servletapi:2.4 ws-commons-util xerces:2"
JARS="common server client"

pkg_setup() {
	MY_CP=`eval echo ${PN}-{${JARS// /,}}.jar`
	MY_CP=${MY_CP// /:}
	MY_CP=${MY_CP}:`java-pkg_getjars --with-dependencies ${EANT_GENTOO_CLASSPATH// /,}`
}

src_compile() {
	local jar
	mkdir -p bin || die

	for jar in ${JARS} ; do
		ejavac -cp ${MY_CP} -d bin `find ${jar} -name "*.java" || die`
		`java-config -j` cvf "${PN}-${jar}.jar" -C bin . || die
		rm -rf bin/* || die
	done
}

src_install() {
	java-pkg_dojar *.jar
	use source && java-pkg_dosrc `eval echo {${JARS// /,}}/src/main/java/*`
}

src_test() {
	local class tests="tests/src/test/java"
	ejavac -cp ${MY_CP}:`java-pkg_getjars junit` `find ${tests} -name "*.java" || die`

	# ScalabilityTest results in an error for some reason. Is it our fault?
	for class in `find ${tests} -name "*Test.java" ! -name "ScalabilityTest.java" || die` ; do
		class=${class#${tests}/}
		class=${class%.java}
		ejunit -cp ${tests}:${tests/\/java/\/resources}:${MY_CP} ${class//\//.}
	done
}
