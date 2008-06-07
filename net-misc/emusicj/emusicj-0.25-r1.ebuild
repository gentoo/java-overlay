# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1
inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="eMusic/J is an open source download manager for the eMusic.com music service written in Java"
HOMEPAGE="http://www.kallisti.net.nz/EMusicJ/HomePage"
SRC_URI="http://www.kallisti.net.nz/wikifiles/EMusicJ/emusicj-source-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

CDEPEND="dev-java/commons-codec:0
	dev-java/commons-httpclient:3
	dev-java/commons-logging:0
	dev-java/guice:0
	dev-java/swt:3"

RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"

DEPEND=">=virtual/jdk-1.5
	${CDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	epatch "${FILESDIR}/${P}-ogg-250.patch"
	rm -r lib/* || die
	java-ant_rewrite-classpath
}

src_compile() {
	eant \
		-Dgentoo.classpath=$(java-pkg_getjars commons-codec,commons-httpclient-3,guice,swt-3):$(java-pkg_getjar commons-logging commons-logging-api.jar) \
		emusicj_props buildjar
}

src_install() {
	java-pkg_dojar ${PN}.jar
	java-pkg_dolauncher ${PN} --main nz.net.kallisti.emusicj.EMusicJ
	newicon images/emusicj_48.png ${PN}.png
	make_desktop_entry ${PN} "EMusic/J" ${PN}.png
}
