# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

IUSE="aac cddb flac gtk mp3 vorbis"

DESCRIPTION="jRipper, a Java frontend to CD ripper and encoder tools"
SRC_URI="http://dronten.googlepages.com/${P}.jar"
HOMEPAGE="http://dronten.googlepages.com/jripper"

LICENSE="GPL-2"
KEYWORDS="~amd64"
SLOT="0"

RDEPEND=">=virtual/jre-1.5
	aac? ( media-libs/faac media-libs/faad2 )
	cddb? ( media-libs/libcddb )
	flac? ( media-libs/flac )
	gtk? ( >=x11-libs/gtk+-2 )
	mp3? ( media-sound/lame )
	vorbis? ( media-sound/vorbis-tools )"
DEPEND=">=virtual/jdk-1.5
	sys-apps/findutils"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd ${S}

	# delete testcode
	rm -rf junit com/googlepages/dronten/jripper/test
	# delete jgoodies
	rm -rf com/jgoodies
	# delete junit & jgoodies license
	rm -rf license.j*

	# delete pre-built code
	find . -type f -name '*.class' -exec rm {} \;
}

src_compile() {
	ejavac $(find com/ -name '*.java') || die "compile failed"
	find com | xargs jar cf ${PN}.jar
}

src_install() {
	java-pkg_dojar ${PN}.jar

	java-pkg_dolauncher ${PN} \
		--main com.googlepages.dronten.jripper.JRipper

	doicon ${FILESDIR}/${PN}.png
	domenu ${FILESDIR}/${PN}.desktop
}
