# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="MP3 decoder/player/converter library for Java"
HOMEPAGE="http://www.javazoom.net/javalayer/javalayer.html"

SRC_URI="mirror://sourceforge/javalayer/${PN}${PV}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"

IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		${RDEPEND}"

S=${WORKDIR}/JLayer${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -v *.jar || die
	# build expects classes to exist
	rm -vr classes/* || die
}

src_compile() {
	eant dist
}

# Needs a test mp3 c:/data/test.mp3
RESTRICT="test"
src_test() {
	cd srctest
	local jar="../jl${PV}.jar"
	ejavac -cp $(java-pkg_getjars junit):${jar} $(find . -name "*.java")
	ejunit -cp ${jar}:. AllTests
}

src_install(){
	java-pkg_newjar jl${PV}.jar ${PN}.jar
	dodoc README.txt CHANGES.txt || die
	dohtml playerapplet.html || die
	use doc && java-pkg_dojavadoc doc
	use source && java-pkg_dosrc src/*

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
