# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="3"
inherit eutils games java-pkg-2 java-pkg-simple

DESCRIPTION="Java port of Lemmings, requires Lemmings for Windows"
HOMEPAGE="http://lemmini.de"
SRC_URI="http://dev.gentooexperimental.org/~chewi/distfiles/${P}.tar.xz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/jnlp-api:0"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.5"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"

JAVA_GENTOO_CLASSPATH="jnlp-api"
JAVA_ENCODING="ISO-8859-1"

S="${WORKDIR}/${P}"

pkg_setup() {
	java-pkg-2_pkg_setup
	games_pkg_setup
}

java_prepare() {
	epatch "${FILESDIR}/userdir.patch"
}

src_compile() {
	java-pkg-simple_src_compile
	jar ufe "${PN}.jar" Lemmini -C bin_copy . || die
}

src_install() {
	java-pkg_dojar "${PN}.jar"
	java-pkg_dolauncher "${PN}" -into "${GAMES_PREFIX}" --main Lemmini

	newicon bin_copy/icon_32.png "${PN}.png" || die
	make_desktop_entry "${PN}" "Lemmini"

	prepgamesdirs
}
