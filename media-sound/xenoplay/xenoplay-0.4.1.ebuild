# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

MY_PV="${PV//./-}"

JAVA_PKG_IUSE="source"
inherit base eutils java-pkg-2

DESCRIPTION="MusicXML player that can output MIDI files"
HOMEPAGE="http://www.xenoage.com/xenoplay.html"
SRC_URI="http://www.xenoage.com/downloads/xenoplay/${PN}-${MY_PV}-src.zip"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="examples"

RDEPEND=">=virtual/jre-1.5"

DEPEND=">=virtual/jdk-1.5"
#	test? ( dev-java/junit:4 )"

S="${WORKDIR}"

src_compile() {
	rm -rf bin/* || die
	ejavac -encoding UTF-8 -d bin $(find src -name '*.java')
	$(java-config -j) cf "${PN}.jar" -C bin com
	$(java-config -j) cf skin.jar data/applet
}

src_install() {
	local share="/usr/share/${PN}"

	java-pkg_dojar "${PN}.jar"
	java-pkg_dojar skin.jar
	java-pkg_dolauncher "${PN}" --main com.xenoage.player.PlayerFrame --pwd "${share}"
	make_desktop_entry "${PN}" "Xenoage Player" "/usr/share/${PN}/data/images/icon.png" || die

	insinto "${share}/data"
	doins -r data/images || die

	if use examples; then
		insinto "${share}"
		doins -r files || die
	fi

	use source && java-pkg_dosrc src/*
	dohtml faq.txt gervill.txt readme.txt || die
}

#src_test() {
#	local junit="$(java-pkg_getjars junit-4)"
#	ejavac -encoding UTF-8 -cp "bin:${junit}" -d bin $(find test -name '*.java')
#	ejunit -cp bin com.xenoage.player.{musicxml.opus.OpusTest,util.io.iocontext.IOContextTest}
#}
