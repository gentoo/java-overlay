# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1
WANT_ANT_TASKS="ant-nodeps"
inherit java-pkg-2 java-ant-2

MY_PN="${PN/jm/jM}"
MY_PV="${PV/_beta/-beta}"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="Java flashcard game"
HOMEPAGE="http://jmemorize.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}-source.zip"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

CDEPEND="dev-java/jfreechart
	dev-java/jgoodies-forms
	dev-java/jcommon
	dev-java/javacsv
	dev-java/itext:1.4"

DEPEND=">=virtual/jdk-1.6
	test? ( dev-java/junit )
	${CDEPEND}"
RDEPEND=">=virtual/jre-1.6
	${CDEPEND}"

S="${WORKDIR}/${MY_P}"
EANT_BUILD_TARGET="dist-bin"
EANT_GENTOO_CLASSPATH="jfreechart-1.0,jgoodies-forms,jcommon-1.0,javacsv,itext-1.4"
RESTRICT="test"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -rfv lib/*.jar || die
	mkdir -p src-test/jmemorize/core/test || die
	mkdir src-test/test || die
	mv -v test/* src-test/test
	mv -v src/jmemorize/core/test/* src-test/jmemorize/core/test || die
	epatch "${FILESDIR}"/buildfixes-1.3.0_beta.patch
	cd src/jmemorize/core || die
	epatch "${FILESDIR}"/loggingfix-1.2.3.patch
	cd io || die
	epatch "${FILESDIR}"/javacvsfix-1.3.0_beta.patch
	#Upstream bug: http://sourceforge.net/tracker/index.php?func=detail&aid=1885123&group_id=121967&atid=691938
	cd "${S}"
	java-ant_rewrite-classpath
}

src_install() {
	newicon resource/icons/main.png ${PN}.png
	java-pkg_newjar dist/${MY_PV}/${MY_P}.jar ${PN}.jar
	java-pkg_dolauncher ${PN} --main jmemorize.core.Main
	make_desktop_entry ${PN} "jMemorize" ${PN}.png
}

src_test() {
	cd "${S}"/src-test
	find . -name '*.java' -print > sources.list
	local cp=../dist/${MY_PV}/${MY_P}.jar:$(java-pkg_getjars --build-only junit):$(java-pkg_getjars jfreechart-1.0,jgoodies-forms,jcommon-1.0,javacsv,itext-1.4)
	ejavac -cp ${cp} @sources.list
	ejunit -cp .:${cp}.jar jmemorize.core.test.AllTests
}
