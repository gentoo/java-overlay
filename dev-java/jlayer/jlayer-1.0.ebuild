# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="MP3 decoder/player/converter library for Java"
HOMEPAGE="http://www.javazoom.net/javalayer/javalayer.html"

SRC_URI="mirror://sourceforge/javalayer/${PN}${PV}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"

IUSE="doc source"

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		app-arch/unzip
		source? ( app-arch/zip )
		${RDEPEND}"

S=${WORKDIR}/JLayer${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -v *.jar
}

src_compile() {
	eant dist
}

src_install(){
	java-pkg_newjar jl${PV}.jar ${PN}.jar
	dodoc README.txt CHANGES.txt
	dohtml playerapplet.html
	use doc && java-pkg_dojavadoc doc

	# the MP3TOWAV converte
	java-pkg_dolauncher jl-converter \
		--main javazoom.jl.converter.jlc

	# the simple MP3 player
	java-pkg_dolauncher jl-player \
		--main javazoom.jl.player.jlp

	# the advanced (threaded) MP3 player
	java-pkg_dolauncher jl-advanced-player \
		--main javazoom.jl.player.advanced.jlap
}
