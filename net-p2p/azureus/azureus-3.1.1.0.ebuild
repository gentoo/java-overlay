# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/azureus/azureus-3.0.5.2.ebuild,v 1.2 2008/04/21 18:40:10 betelgeuse Exp $

###
### @Todo The new Azureus gui requires swt built with embedded mozilla support,
###       or azureus will hang at startup. However, you can still start
###       the old GUI which doesn't require it, by using file/restart (which
###       is kind of bug, and maybe I should put that patch, that removes
###       restart from menu, back). It probably could be invoked also by using
###       a different Main class (look for them there are plenty :) so we could
###       have some old-gui flag which would run that one and remove
###       the mozilla dep. Best would be some per-user setting and startup
###       script check for swt mozilla support and die...
###

EAPI=1

JAVA_PKG_IUSE="source"

inherit eutils fdo-mime java-pkg-2 java-ant-2

DESCRIPTION="BitTorrent client in Java"
HOMEPAGE="http://azureus.sourceforge.net/"
SRC_URI="mirror://sourceforge/azureus/Vuze_${PV}_source.zip
	http://azureus.sourceforge.net/plugins/azupdater_1.8.8.zip"
LICENSE="GPL-2 BSD"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-java/json-simple:0
	>=dev-java/bcprov-1.35:0
	>=dev-java/commons-cli-1.0:1
	>=dev-java/log4j-1.2.8:0
	>=dev-java/swt-3.4_pre6-r1:3.4
	!net-p2p/azureus-bin
	>=virtual/jre-1.5"

DEPEND="${RDEPEND}
	app-arch/unzip
	dev-util/desktop-file-utils
	>=virtual/jdk-1.5"

JAVA_PKG_FILTER_COMPILER="jikes"

S="${WORKDIR}"

pkg_setup() {
	if ! built_with_use --missing false -o dev-java/swt firefox seamonkey xulrunner; then
		eerror "dev-java/swt:3.4 must be compiled with the firefox, seamonkey or xulrunner USE flag"
		eerror "(support may vary per swt version) or azureus will hang at startup!"
		die "recompile dev-java/swt:3.4 with embedded browser"
	fi
	java-pkg-2_pkg_setup
}

src_unpack() {
	unpack ${A}
	unzip -q Updater.jar || die
	unzip -q azupdaterpatcher_1.8.8.jar || die
	rm -v org/gudy/azureus2/update/*.class || die

	epatch "${FILESDIR}/patches-3.1.1.0/use-jdk-cipher-only.diff"
	epatch "${FILESDIR}/patches-3.1.1.0/remove-osx-platform.diff"
	epatch "${FILESDIR}/patches-3.0.5.2/no-debug.patch"

	### Removes OS X files and entries.
	rm -rv "org/gudy/azureus2/platform/macosx" \
		   "org/gudy/azureus2/ui/swt/osx" || die

	### Removes Windows files.
	rm -v ./org/gudy/azureus2/ui/swt/win32/Win32UIEnhancer.java || die

	### Removes test files.
	rm -rv "org/gudy/azureus2/ui/swt/test" \
		org/gudy/azureus2/ui/console/multiuser/TestUserManager.java || die

	### Removes bouncycastle (we use our own bcprov).
	rm -rv "org/bouncycastle" || die

	### Removes bundled json
	rm -rv "org/json" || die

	mkdir -p build/libs || die
}

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_GENTOO_CLASSPATH="swt-3.4,bcprov,json-simple,log4j,commons-cli-1"

src_compile() {
	local mem
	use amd64 && mem="256"
	use x86   && mem="128"
	use ppc   && mem="192"
	export ANT_OPTS="-Xmx${mem}m"
	java-pkg-2_src_compile
}

src_install() {
	java-pkg_dojar dist/*.jar || die "dojar failed"
	dodoc ChangeLog.txt || die

	java-pkg_dolauncher "${PN}" \
		--main 'org.gudy.azureus2.${UI}.Main' -pre "${FILESDIR}/${PN}-3.0.5.2-pre" \
		--java_args '-Dazureus.install.path=${HOME}/.azureus/ ${JAVA_OPTIONS}'

	# https://bugs.gentoo.org/show_bug.cgi?id=204132
	java-pkg_register-environment-variable MOZ_PLUGIN_PATH /usr/lib/nsbrowser/plugins

	doicon "${FILESDIR}/azureus.png"
	domenu "${FILESDIR}/azureus.desktop"

	use source && java-pkg_dosrc "${S}"/{com,edu,org}
}

pkg_postinst() {
	###
	### @Todo We should probably deactivate auto-update it by default,
	###       or even remove the option.
	###
	elog "It is not recommended to use the Azureus auto-update feature,"
	elog "and it might not even work. You should disable auto-update via"
	elog "Tools > Options > Interface > Start"
	elog
	elog "After running azureus for the first time, configuration"
	elog "options will be placed in '~/.azureus/gentoo.config'."
	elog "If you need to change some startup options, you should"
	elog "modify this file, rather than the startup script."
	elog
	elog "Using this config file you can start the console UI."
	echo
	elog "To switch from classic UI to Vuze use"
	elog "1: Tools > Options > Interface > Start > Display Azureus UI Chooser"
	elog "2: Toolbar (right-hand side)"
	echo
	elog "If you have problems starting Azureus, try starting it"
	elog "from the command line to look at debugging output."
	echo
	ewarn "Running Azureus as root is not supported."

	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
