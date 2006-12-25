# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/poi/poi-2.5.1.ebuild,v 1.4 2005/12/16 14:08:33 betelgeuse Exp $

inherit java-pkg-2 java-ant-2 versionator

DESCRIPTION="Java API To Access Microsoft Format Files"
HOMEPAGE="http://jakarta.apache.org/poi/"
MY_PV=$(replace_version_separator 2 '-' ${PV})
RELEASE_DATE="20061212"
SRC_URI="mirror://apache/jakarta/poi/dev/src/${PN}-src-${MY_PV}-${RELEASE_DATE}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc source test"

RDEPEND=">=virtual/jre-1.2
	>=dev-java/commons-logging-1.1
	>=dev-java/log4j-1.2.13
	=dev-java/commons-beanutils-1.7*
	>=dev-java/commons-collections-3.2
	=dev-java/commons-lang-2.1*"
DEPEND=">=virtual/jdk-1.2
	${RDEPEND}
	>=dev-java/ant-core-1.4
	test? ( =dev-java/junit-3.8*
		>=dev-java/ant-junit-1.4 )"

S=${WORKDIR}

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${P}-build.xml.patch
	epatch ${FILESDIR}/${P}-src.patch

	cd ${S}/lib
	rm -f *.jar
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.1.jar
	java-pkg_jar-from log4j log4j.jar log4j-1.2.13.jar
	use test && java-pkg_jar-from junit junit.jar junit-3.8.1.jar

	cd ${S}/src/contrib/lib
	rm -f *.jar
	java-pkg_jar-from commons-beanutils-1.7 commons-beanutils.jar commons-beanutils-1.7.0.jar
	java-pkg_jar-from commons-collections commons-collections.jar commons-collections-3.2.jar
	java-pkg_jar-from commons-lang commons-lang.jar commons-lang-2.1.jar
}

src_compile() {
	eant jar -Ddisconnected=true $(use_doc javadocs)
}

src_test() {
	ANT_TASKS="ant-junit" eant test -Ddisconnected=true
}

src_install() {
	use doc && java-pkg_dohtml -r build/tmp/site/build/site/*
	use source && java-pkg_dosrc src/contrib/src/org src/java/org/ src/scratchpad/src/org

	cd build/dist/
	local VERSION=$(get_version_component_range 1-2 ${PV})
	java-pkg_newjar poi-scratchpad-${VERSION}* ${PN}-scratchpad.jar
	java-pkg_newjar poi-contrib-${VERSION}* ${PN}-contrib.jar
	java-pkg_newjar poi-${VERSION}* ${PN}.jar
}
