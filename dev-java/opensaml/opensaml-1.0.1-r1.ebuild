# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="an Open Source Security Assertion Markup Language implementation"
HOMEPAGE="http://www.opensaml.org/"
SRC_URI="http://shibboleth.internet2.edu/downloads/archive/${PN}-java-${PV}.tar.gz"

LICENSE="Apache 2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4
	=dev-java/xerces-2.6*
	=dev-java/xml-commons-external-1.3*
	=dev-java/servletapi-2.3*
	dev-java/xalan
	=dev-java/xml-security-1.3*"

S="${WORKDIR}/${PN}/java"

JUNIT="junit junit.jar"
LOG4J="log4j log4j.jar"
# The packed jar _says_ 2.2, but 2.3 works fine
SERVLET="servletapi-2.3 servlet.jar"
XMLSEC="xml-security-1.3 xmlsec.jar"

EANT_BUILD_TARGET="dist"
EANT_DOC_TARGET="javadocs"
EANT_GENTOO_CLASSPATH="xalan xml-security-1.3 servletapi-2.3"

src_unpack() {
	unpack ${A}

	rm -f "${S}/dist/opensaml.jar" || die "rm failed"

	cd "${S}" || die "cd failed"
	epatch ${FILESDIR}/${P}-ioexception.patch

	cd "${S}/endorsed" || die "cd failed"
	java-pkg_jar-from xerces-2.6                xercesImpl.jar dom3-xercesImpl-2.5.0.jar
	java-pkg_jar-from xml-commons-external-1.3  xml-apis.jar  dom3-xml-apis-2.5.0.jar

	cd "${S}/lib" || die "cd failed"
	rm *.jar || die "rm failed"
	java-pkg_jar-from ${LOG4J}
	java-pkg_jar-from ${SERVLET}
	java-pkg_jar-from ${XMLSEC}

	for build in $(find "${S}" -name build*.xml );do
		java-ant_rewrite-classpath "${build}"
	done
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	dodoc doc/*.txt

	use doc && java-pkg_dohtml -r doc/api
}
