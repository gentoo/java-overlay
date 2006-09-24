# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/poi/poi-2.5.1.ebuild,v 1.4 2005/12/16 14:08:33 betelgeuse Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Java API To Access Microsoft Format Files"
HOMEPAGE="http://jakarta.apache.org/poi/"
SRC_URI="mirror://apache/jakarta/poi/release/src/${PN}-src-${PV}-final-20040804.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc source"

RDEPEND=">=virtual/jre-1.2
	>=dev-java/commons-logging-1.0
	>=dev-java/log4j-1.2.8
	=dev-java/commons-beanutils-1.6*
	>=dev-java/commons-collections-2.1
	=dev-java/commons-lang-2.0*
	>=dev-java/xerces-2.6
	>=dev-java/gnu-jaxp-1.0"
DEPEND=">=virtual/jdk-1.2
	${RDEPEND}
	>=dev-java/ant-core-1.4"

S=${WORKDIR}

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${PN}-2.5-jikes-fix.patch
	epatch ${FILESDIR}/${P}-build.xml.patch

	cd ${S}/lib
	rm -f *.jar
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.0.1.jar
	java-pkg_jar-from log4j log4j.jar log4j-1.2.8.jar

	cd ${S}/src/contrib/lib
	rm -f *.jar
	java-pkg_jar-from commons-beanutils-1.6 commons-beanutils.jar commons-beanutils-1.6.jar
	java-pkg_jar-from commons-collections commons-collections.jar commons-collections-2.1.jar
	java-pkg_jar-from commons-lang commons-lang.jar commons-lang-1.0-b1.jar
	java-pkg_jar-from gnu-jaxp gnujaxp.jar xmlParserAPIs-2.2.1.jar
	java-pkg_jar-from xerces-2 xercesImpl.jar xercesImpl-2.4.0.jar
}

src_compile() {
	eant jar
}

src_install() {
	use doc && java-pkg_dohtml -r docs/*
	use source && java-pkg_dosrc src/contrib/src/org src/java/org/ src/scratchpad/src/org

	cd build/dist/
	java-pkg_newjar poi-scratchpad-${PV}* ${PN}-scratchpad.jar
	java-pkg_newjar poi-contrib-${PV}* ${PN}-contrib.jar
	java-pkg_newjar poi-${PV}* ${PN}.jar
}
