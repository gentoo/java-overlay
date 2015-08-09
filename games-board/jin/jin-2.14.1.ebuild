# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"
WANT_ANT_TASKS="ant-nodeps"

inherit eutils games java-pkg-2 java-ant-2

DESCRIPTION="Java client for various chess servers"
HOMEPAGE="http://www.jinchess.com"
SRC_URI="mirror://sourceforge/${PN}/${P}-source.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.2"
RDEPEND=">=virtual/jre-1.4"

EANT_BUILD_TARGET="build"

java_prepare() {
	# Delete some bundled JARs but not all. We don't have bsh-1 in the
	# tree any more and I don't know how to migrate this. There are also
	# no sources available for timestamping.jar and timesealing.jar.
	find resources/{lnfs,os-specific} -name "*.jar" -exec rm -v {} \; || die

	# Use our rewritten source/target instead.
	sed -i '/<compilerarg /d' build.xml || die
}

src_install() {
	local DIR="${GAMES_DATADIR}/${PN}"

	java-pkg_jarinto "${DIR}"
	insinto "${DIR}"

	rm -rf build/libs/{fics,icc} build/libs/bsh-core-1.*.jar || die
	java-pkg_dojar build/*.jar resources/libs/{fics,icc}/*.jar resources/libs/bsh-core-1.*.jar
	doins -r build/{actions,libs,plugins,resources,servers} || die

	java-pkg_dolauncher "${PN}" -into "${GAMES_PREFIX}" \
		--pwd "${DIR}" --main free.jin.JinApplication

	newicon src/free/jin/resources/logo.gif "${PN}.gif" || die
	make_desktop_entry "${PN}" "Jin"

	dodoc changelog.txt COMPILING || die

	prepgamesdirs
}
