# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/fop/fop-0.20.5-r3.ebuild,v 1.10 2006/01/23 14:13:00 nichoj Exp $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Formatting Objects Processor is a print formatter driven by XSL"
HOMEPAGE="http://xmlgraphics.apache.org/fop/"
SRC_URI="mirror://apache/xmlgraphics/${PN}/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"

KEYWORDS=""
#IUSE="doc examples jai jimi mathml xmlunit"
IUSE="examples source"
#removed doc as unable to get it to build (Outofmem errors)

RDEPEND=">=virtual/jre-1.5
	=dev-java/avalon-framework-4.2*
	dev-java/xalan
	=dev-java/batik-1.6*
	>=dev-java/xerces-2.6.2
	dev-java/commons-io
	dev-java/commons-logging
	>=dev-java/xmlgraphics-commons-1.0
	=dev-java/servletapi-2.2*"
	#mathml? ( dev-java/jeuclid )"
	#jai? ( dev-java/sun-jai-bin )
	#jimi? ( dev-java/sun-jimi )
	#xmlunit? ( dev-java/xmlunit )
DEPEND=">=virtual/jdk-1.5
	=dev-java/eclipse-ecj-3.2*
	${RDEPEND}
	>=dev-java/ant-1.5.4
	source? ( app-arch/zip )
	!dev-java/fop-bin
	dev-java/sun-jai-bin
	dev-java/sun-jimi
	dev-java/xmlunit"

src_unpack() {
	unpack ${A}
	#epatch ${FILESDIR}/${P}-startscript.patch

	cd ${S}/lib
	local packages="avalon-framework-4.2 xalan xmlgraphics-commons-1 xerces-2
	commons-io-1 servletapi-2.2 batik-1.6"

	for package in ${packages}; do
		java-pkg_jarfrom ${package}
	done
	java-pkg_jar-from sun-jai-bin
	#if use jimi; then
		java-pkg_jar-from sun-jimi
	#fi
	#if use xmlunit; then
		java-pkg_jar-from xmlunit-1
	#fi
	#if use mathml; then
	#	cd ${S}/examples/mathml/lib
#		java-pkg_jar-from jeuclid
	#fi
}

ANT_OPTS="-XX:MaxPermSize=512m"
EANT_BUILD_TARGET="package"
#EANT_DOC_TARGET="javadocs"
#JAVA_PKG_FORCE_COMPILER="ecj-3.2"

src_install() {
	#java-pkg_dojar lib/batik*.jar
	#java-pkg_dojar lib/xmlgraphics-commons*.jar

	java-pkg_dojar build/*.jar
	#if use mathml; then
	#	java-pkg_dojar examples/mathml/build/mathml-fop.jar
	#fi

	#doexe ${PN}

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
