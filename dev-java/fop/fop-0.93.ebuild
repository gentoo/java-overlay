# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/fop/fop-0.20.5-r3.ebuild,v 1.10 2006/01/23 14:13:00 nichoj Exp $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Formatting Objects Processor is a print formatter driven by XSL"
HOMEPAGE="http://xmlgraphics.apache.org/fop/"
SRC_URI="mirror://apache/xmlgraphics/${PN}/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0.93"

KEYWORDS="~amd64"
#IUSE="doc examples jai jimi mathml xmlunit"
IUSE="examples source jai jimi xmlunit"
#removed doc as unable to get it to build (Outofmem errors)

RDEPEND=">=virtual/jre-1.4
	=dev-java/avalon-framework-4.2*
	dev-java/xalan
	=dev-java/batik-1.6*
	>=dev-java/xerces-2.6.2
	dev-java/commons-io
	dev-java/commons-logging
	dev-java/xml-commons
	>=dev-java/xmlgraphics-commons-1.1
	=dev-java/servletapi-2.2*
	jai? ( dev-java/sun-jai-bin )
	jimi? ( dev-java/sun-jimi )
	xmlunit? ( dev-java/xmlunit )"
DEPEND=">=virtual/jdk-1.4
	=dev-java/eclipse-ecj-3.2*
	${RDEPEND}
	>=dev-java/ant-1.5.4
	source? ( app-arch/zip )"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	epatch "${FILESDIR}/${P}-gentoo-startscript.patch"

	cd "${S}/lib"
	rm *.jar

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
	use xmlunit && java-pkg_jar-from xmlunit-1
}

ANT_OPTS="-XX:MaxPermSize=512m"
EANT_BUILD_TARGET="package"
#EANT_DOC_TARGET="javadocs"
JAVA_PKG_FORCE_COMPILER="ecj-3.2"

src_install() {
	
	java-pkg_dojar build/*.jar
	
	# This could be useful once I figure out what 
	# and where the mathml jar comesfrom
	
	#if use mathml; then
	#	java-pkg_dojar examples/mathml/build/mathml-fop.jar
	#fi

	#cd lib
	#java-pkg_regjar *.jar
	#cd "${S}"
	
	dobin fop

	#for when the time is right
	#if use doc; then
	#	dodoc CHANGES STATUS README
	#	dohtml ReleaseNotes.html 
	#	java-pkg_dojavadoc build/javadocs/*
	#fi

	if use examples; then
		dodir /usr/share/doc/${PF}/examples
		cp -pPR examples ${D}/usr/share/doc/${PF}/examples
	fi
}

