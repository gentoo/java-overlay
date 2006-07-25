# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="an Open Source Security Assertion Markup Language implementation"
HOMEPAGE="http://www.opensaml.org/"
SRC_URI="http://shibboleth.internet2.edu/downloads/archive/${PN}-java-${PV}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND="=virtual/jre-1.4*
	=dev-java/servletapi-2.3*
	dev-java/xalan
	=dev-java/xml-security-1.2*"

JAVA_PKG_NV_DEPEND="=virtual/jdk-1.4*"

S="${WORKDIR}/${PN}/java"

JUNIT="junit junit.jar"
LOG4J="log4j log4j.jar"
# The packed jar _says_ 2.2, but 2.3 works fine
SERVLET="servletapi-2.3 servlet.jar"
XMLSEC="xml-security-1.2 xmlsec.jar"

src_unpack() {
	unpack ${A}
	
	cd ${S}
#	epatch ${FILESDIR}/${P}-ioexception.patch

	cd ${S}/lib
	rm *.jar
	java-pkg_jar-from ${LOG4J}
	java-pkg_jar-from ${SERVLET}
	java-pkg_jar-from ${XMLSEC}
}

src_compile() {
	eant dist $(use_doc javadocs)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	dodoc doc/*.txt

	use doc && java-pkg_dohtml -r doc/api
}
