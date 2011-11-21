# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit games

DESCRIPTION="Common scripts for Minecraft servers"
HOMEPAGE="http://www.minecraft.net"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="app-misc/tmux
	>=sys-apps/openrc-0.3.0
	!!=games-server/minecraft-server-201*"

S="${WORKDIR}"

DIR="/var/lib/minecraft"
PID="/var/run/minecraft"

src_prepare() {
	cp "${FILESDIR}"/{init,console}.sh . || die
	sed -i "s/@GAMES_USER_DED@/${GAMES_USER_DED}/g" init.sh || die
	sed -i "s/@GAMES_GROUP@/${GAMES_GROUP}/g" console.sh || die
}

src_install() {
	diropts -o "${GAMES_USER_DED}" -g "${GAMES_GROUP}"
	keepdir "${DIR}" "${PID}" || die
	gamesperms "${D}${DIR}" "${D}${PID}" || die

	newinitd init.sh minecraft-server || die
	newgamesbin console.sh minecraft-server-console || die

	prepgamesdirs
}

pkg_postinst() {
	ewarn "This package does nothing by itself. You need to install"
	ewarn "games-server/minecraft-server or games-server/craftbukkit."
	echo

	games_pkg_postinst
}
