# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/fop/fop-0.20.5-r3.ebuild,v 1.10 2006/01/23 14:13:00 nichoj Exp $

# TODO: currently JCE support depends on availability of JCE in JDK, that should be changed
#       so the build is always exactly the same with the same use flags
# TODO: hyphenation support doesn't seem to be built correctly
# TODO: headless tests fails with java.awt.headless=true so maybe they should be fully disabled
# TODO: if 'doc' use flag is used then build also extra docs ('docs' ant target), currently it cannot
#       be built as it needs forrest which we do not have

JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Formatting Objects Processor is a print formatter driven by XSL"
HOMEPAGE="http://xmlgraphics.apache.org/fop/"
SRC_URI="mirror://apache/xmlgraphics/${PN}/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0.93"

KEYWORDS="~amd64 ~x86"
IUSE="examples jai jimi test"

COMMON_DEPEND="
	>=dev-java/avalon-framework-4.2
	>=dev-java/batik-1.6
	dev-java/commons-io
	dev-java/commons-logging
	=dev-java/servletapi-2.2*
	dev-java/xalan
	>=dev-java/xerces-2.7
	dev-java/xml-commons
	>=dev-java/xmlgraphics-commons-1.1
	jai? ( dev-java/sun-jai-bin )
	jimi? ( dev-java/sun-jimi )"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"

DEPEND=">=virtual/jdk-1.4
	${COMMON_DEPEND}
	>=dev-java/ant-1.5.4
	test? (
		=dev-java/junit-3.8*
		dev-java/xmlunit
	)"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	epatch "${FILESDIR}/${P}-gentoo-startscript.patch"

	cd "${S}/lib"
	rm *.jar

	java-pkg_jarfrom ant-core ant.jar
	java-pkg_jarfrom avalon-framework-4.2 avalon-framework.jar \
		avalon-framework-4.2.0.jar
	java-pkg_jarfrom batik-1.6 batik-all.jar batik-all-1.6.jar
	java-pkg_jarfrom commons-io-1 commons-io.jar commons-io-1.1.jar
	java-pkg_jarfrom commons-logging commons-logging.jar \
		commons-logging-1.0.4.jar
	java-pkg_jarfrom xalan serializer.jar serializer-2.7.0.jar
	java-pkg_jarfrom servletapi-2.2 servlet.jar servlet-2.2.jar
	java-pkg_jarfrom xalan xalan.jar xalan-2.7.0.jar
	java-pkg_jarfrom xerces-2 xercesImpl.jar xercesImpl-2.7.1.jar
	java-pkg_jarfrom xml-commons xml-apis.jar xml-apis-1.3.02.jar
	java-pkg_jarfrom xmlgraphics-commons-1 xmlgraphics-commons.jar \
		xmlgraphics-commons-1.1.jar

	use jai && java-pkg_jar-from sun-jai-bin
	use jimi && java-pkg_jar-from sun-jimi
}

EANT_BUILD_TARGET="package"
EANT_DOC_TARGET="javadocs"

src_test() {
	if use test ; then
		cd "${S}/lib"
		java-pkg_jar-from xmlunit-1
		java-pkg_jar-from junit
		cd "${S}"
	fi

	ANT_OPTS="-Xmx1g -Djava.awt.headless=true" eant -Djunit.fork=off junit
}

src_install() {
	for JAR in fop-hyph.jar fop.jar fop-sandbox.jar; do
		java-pkg_dojar build/${JAR}
	done

	dobin fop

	if use doc; then
		dodoc NOTICE README
		java-pkg_dojavadoc build/javadocs
	fi

	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -pPR examples/* ${D}/usr/share/doc/${PF}/examples
	fi

	use source && java-pkg_dosrc src/java/org src/java-1.4/* src/sandbox/org
}
