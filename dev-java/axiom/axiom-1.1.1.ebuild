# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Apache WSS4J is an implementation of the OASIS Web Services Security (WS-Security)"
HOMEPAGE="http://ws.apache.org/wss4j/index.html"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 "
IUSE="doc source"

DEPEND="|| ( =virtual/jdk-1.4*  =virtual/jdk-1.5* =virtual/jdk-1.6* )
		source? ( app-arch/zip )
		dev-java/commons-logging
		dev-java/stax
		dev-java/log4j
		dev-java/junit
		=dev-java/jaxen-1.1
		=dev-java/xmlunit-1*
		dev-java/sun-javamail
		dev-java/sun-jaf
		=dev-java/xml-commons-external-1.3*"
		# stax !
RDEPEND="${DEPEND} >=virtual/jre-1.4"
EANT_BUILD_TARGET="compile jar"
EANT_DOC_TARGET="javadoc"
EANT_GENTOO_CLASSPATH="stax,commons-logging,log4j,jaxen-1.1,junit,xmlunit-1,sun-javamail,sun-jaf,xml-commons-external-1.3"

src_unpack(){
	unpack ${A}
	cp "${FILESDIR}/build.xml" "${S}" || die "cp failed"
	java-ant_rewrite-classpath "${S}/build.xml"
}

src_install() {
	java-pkg_dojar  "${S}/dist/lib/${PN}.jar"
	use doc && java-pkg_dojavadoc "${S}/dist/docs"
	use source && java-pkg_dosrc  "${S}/modules"
}
