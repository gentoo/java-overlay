# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

WANT_ANT_TASKS="ant-junit"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Apache WSS4J is an implementation of the OASIS Web Services Security (WS-Security)"
HOMEPAGE="http://ws.apache.org/wss4j/index.html"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 "
IUSE="doc source"

DEPEND=">=virtual/jdk-1.5
		source? ( app-arch/zip )
		dev-java/axiom
		dev-java/junit
		dev-java/stax
		=www-servers/axis-1*
		dev-java/commons-logging"
RDEPEND="${DEPEND} >=virtual/jre-1.5"

EANT_BUILD_TARGET="compile.library compile.interops jar"
EANT_DOC_TARGET="javadoc"
EANT_GENTOO_CLASSPATH="axis-1,stax,axiom,junit,commons-logging"

src_unpack(){
	unpack ${A}
	cp "${FILESDIR}/build.xml" "${S}" || die "cd failed"
	java-ant_rewrite-classpath "${S}/build.xml"
}

src_install() {
	java-pkg_dojar "${S}"/dist/lib/*.jar
	use doc && java-pkg_dojavadoc "${S}/dist/docs"
	use source && java-pkg_dosrc  "${S}/src"
}
