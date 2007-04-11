# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc examples source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="a Java library for handling iCalendar data streams"
HOMEPAGE="http://ical4j.sourceforge.net/"
MY_PV=${PV/_/-}
MY_P=${PN}-${MY_PV}
SRC_URI="mirror://sourceforge/${PN}/${MY_P}-src.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"

COMMON_DEP="
	dev-java/commons-logging
	dev-java/commons-codec
	=dev-java/commons-lang-2.1*
	"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	dev-java/emma
	${COMMON_DEP}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	java-ant_rewrite-classpath
	rm -v lib/*.jar || die
	mkdir bin || die
}

ANT_TASKS="emma"
EANT_BUILD_TARGET="package"
EANT_GENTOO_CLASSPATH="commons-logging,commons-codec,commons-lang-2.1"
EANT_EXTRA_ARGS="-Demma.dir=/usr/share/ant-core/lib/"

RESTRICT="test"
# two tests fail with maven, they work in HEAD
src_test() {
	local dcp="$(java-pkg_getjars --with-dependencies ${EANT_GENTOO_CLASSPATH})"
	ANT_TASKS="ant-junit emma" eant run-tests \
		-Dproject.classpath="${dcp}"
}

src_install() {
	java-pkg_dojar build/*.jar
	dodoc README AUTHORS CHANGELOG || die
	dodoc etc/FAQ etc/TODO etc/standard_deviations.txt || die
	use doc && java-pkg_dojavadoc docs/api
	use source && java-pkg_dosrc source/net
	use examples && java-pkg_doexamples etc/samples
}
