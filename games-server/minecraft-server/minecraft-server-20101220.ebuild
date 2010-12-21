# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit games java-pkg-2

DESCRIPTION="Dedicated server for Minecraft"
HOMEPAGE="http://www.minecraft.net"
SRC_URI="http://www.minecraft.net/download/minecraft_server.jar -> ${P}.jar"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

DEPEND="virtual/jdk:1.6"
RDEPEND="virtual/jre:1.6"

S="${WORKDIR}"

src_unpack() {
	true # NOOP!
}

src_install() {
	java-pkg_newjar "${DISTDIR}/${P}.jar" "${PN}.jar"

	java-pkg_dolauncher "${PN}" -into "${GAMES_PREFIX}" \
		-pre "${FILESDIR}/mkdir.sh" \
		--pwd '${HOME}/.minecraft/server' \
		--java_args "-Xmx1024M -Xms512M" \
		--pkg_args "nogui"

	prepgamesdirs
}

pkg_postinst() {
	ewarn "Type minecraft-server at the console to start the server. All server"
	ewarn "files are stored in ~/.minecraft/server."
	echo

	games_pkg_postinst
}
