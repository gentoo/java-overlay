# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
inherit systemd games

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
	keepdir "${DIR}" "${PID}"
	gamesperms "${D}${DIR}" "${D}${PID}"

	newinitd init.sh minecraft-server
	newgamesbin console.sh minecraft-server-console
	systemd_dotmpfilesd "${FILESDIR}/systemd/minecraft.conf"

	prepgamesdirs
}

pkg_postinst() {
	ewarn "This package does nothing by itself. You need to install"
	ewarn "games-server/minecraft-server or games-server/craftbukkit."
	echo

	games_pkg_postinst
}
