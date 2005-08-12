# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

DESCRIPTION="an Open Source Security Assertion Markup Language implementation"
HOMEPAGE="http://www.opensaml.org/"
SRC_URI="http://wayf.internet2.edu/shibboleth/opensaml-java-1.0.1.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

DEPEND="=virtual/jdk-1.4*
	dev-java/ant"
RDEPEND="=virtual/jre-1.4*
	=dev-java/servletapi-2.3*
	dev-java/xalan
	dev-java/xml-security"

S="${WORKDIR}/${PN}/java"

JUNIT="junit junit.jar"
LOG4J="log4j log4j.jar"
# The packed jar _says_ 2.2, but 2.3 works fine
SERVLET="servletapi-2.3 servlet.jar"
XMLSEC="xml-security xmlsec.jar"

src_unpack() {
	unpack ${A}
	
	cd ${S}
	epatch ${FILESDIR}/${P}-ioexception.patch

	cd ${S}/lib
	# We're going to start from scratch...lots of cruff in the lib directory
	rm *.jar
	java-pkg_jar-from ${LOG4J}
	java-pkg_jar-from ${SERVLET}
	java-pkg_jar-from ${XMLSEC}
}

src_compile() {
	local antflags="dist"
	use doc && antflags="${antflags} javadocs"

	ant ${antflags} || die "Compile failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	dodoc doc/*.txt

	use doc && java-pkg_dohtml -r doc/api

}
