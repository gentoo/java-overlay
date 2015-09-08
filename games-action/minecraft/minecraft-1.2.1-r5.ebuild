# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python{2_7,3_1,3_2,3_3} )

inherit eutils python-r1 games java-pkg-2

DESCRIPTION="A game about placing blocks while running from skeletons. Or something like that..."
HOMEPAGE="http://www.minecraft.net"
SRC_URI="https://s3.amazonaws.com/Minecraft.Download/launcher/Minecraft.jar -> $P.jar"
LICENSE="Minecraft"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RESTRICT="mirror"

DEPEND="app-arch/zip
	>=virtual/jdk-1.6"

RDEPEND="dev-java/gson:2.2.2
	dev-java/java-config:2
	>=dev-java/jopt-simple-4.5:0
	>=virtual/jre-1.6

	>=dev-java/bcprov-1.47:0
	>=dev-java/commons-io-2.4:1
	dev-java/commons-lang:3.1
	dev-java/guava:14
	>=dev-java/jinput-1_pre20100416:0
	dev-java/jutils:0
	dev-java/lwjgl:2.9
	dev-java/paulscode-codecjorbis:0
	dev-java/paulscode-codecwav:0
	dev-java/paulscode-librarylwjglopenal:0
	dev-java/paulscode-libraryjavasound:0
	dev-java/paulscode-soundsystem:0"

S="${WORKDIR}"

pkg_setup() {
	java-pkg-2_pkg_setup
	games_pkg_setup
}

src_unpack() {
	zip -d "${DISTDIR}/${A}" -O "${PN}.jar" --temp-path "${T}" com/\* joptsimple/\* || die
}

src_prepare() {
	sed "s:@GENTOO_PORTAGE_EPREFIX@:${EPREFIX}:g" "${FILESDIR}/${PN}-gentoo" > "${PN}-gentoo" || die
}

src_install() {
	# These dependencies are used by the launcher. The others are used
	# by the game itself and are sourced using the wrapper below.
	java-pkg_register-dependency gson-2.2.2
	java-pkg_register-dependency jopt-simple

	python_scriptinto "${GAMES_PREFIX}/bin"
	python_foreach_impl python_doscript "${PN}-gentoo"

	java-pkg_dojar "${PN}.jar"
	java-pkg_dolauncher "${PN}" -into "${GAMES_PREFIX}" --main net.minecraft.bootstrap.Bootstrap

	doicon "${FILESDIR}/${PN}.png"
	make_desktop_entry "${PN}" "Minecraft"

	prepgamesdirs
}

pkg_postinst() {
	ewarn "The Minecraft launcher uses Gentoo's own packages but the game itself"
	ewarn "uses upstream libraries by default. Using Gentoo's packages for the game"
	ewarn "is recommended. Just follow these steps..."
	ewarn ""
	ewarn " # Start the launcher"
	ewarn " # Log in"
	ewarn " # Click Edit Profile"
	ewarn " # Tick the Executable check box"
	ewarn " # Replace the text box content with minecraft-gentoo"
	ewarn " # Click Save Profile"
	ewarn " # Play!"
	ewarn ""
	ewarn "You can revert to upstream libraries by unticking the check box. When"
	ewarn "reporting bugs to Gentoo, please state whether you are using upstream"
	ewarn "libraries or not. Always use upstream libraries when reporting bugs"
	ewarn "upstream."
	echo

	games_pkg_postinst
}
