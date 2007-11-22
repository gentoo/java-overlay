# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/azureus/azureus-2.5.0.4-r1.ebuild,v 1.5 2007/06/14 00:41:43 angelos Exp $

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

JAVA_PKG_IUSE="source"

inherit eutils fdo-mime java-pkg-2 java-ant-2

DESCRIPTION="BitTorrent client in Java"
HOMEPAGE="http://azureus.sourceforge.net/"
SRC_URI="mirror://sourceforge/azureus/Azureus_${PV}_source.zip"
LICENSE="GPL-2 BSD"

SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="
	>=dev-java/bcprov-1.35
	>=dev-java/commons-cli-1.0
	>=dev-java/log4j-1.2.8
	>=dev-java/swt-3.3_pre3
	!net-p2p/azureus-bin
	>=virtual/jre-1.5"

DEPEND="${RDEPEND}
	app-arch/unzip
	dev-util/desktop-file-utils
	>=virtual/jdk-1.5"

S="${WORKDIR}"

pkg_setup() {
	if ! built_with_use --missing false -o dev-java/swt firefox seamonkey xulrunner; then
		eerror
		eerror "dev-java/swt must be compiled with the firefox, seamonkey or xulrunner USE flag"
		eerror "(support may vary per swt version) or azureus will hang at startup!"
		eerror
		die "recompile dev-java/swt with embedded browser"
	fi
}

src_unpack() {
	unpack "${A}"

	### Patches Azureus to use bcprov,
	EPATCH_SUFFIX="patch" epatch "${FILESDIR}/patches-${PV}"

	### Remove an unit test we never run
	rm -v ./org/gudy/azureus2/ui/console/multiuser/TestUserManager.java || die

	### Removes OS X files and entries.
	rm -rv "org/gudy/azureus2/platform/macosx" \
	       "org/gudy/azureus2/ui/swt/osx"      || die

	### Removes Windows files.
	rm -rv "com/aelitis/azureus/util/win32"   \
	       "org/gudy/azureus2/platform/win32" \
	       "org/gudy/azureus2/ui/swt/win32"   || die

	### Removes test files.
	rm -rv "org/gudy/azureus2/ui/swt/test" || die

	### Removes bouncycastle (we use our own bcprov).
	rm -rv "org/bouncycastle" || die
}

src_compile() {
	local mem
	use amd64 && mem="256"
	use x86   && mem="128"
	use ppc   && mem="192"
	ejavac -J-Xmx${mem}m -encoding latin1 \
		-classpath $(java-pkg_getjars swt-3,commons-cli-1,log4j,bcprov) \
		$(find . -name "*.java")
	jar cf azureus.jar $(find . -type f -a ! -name "*.java")
}

src_install() {

	java-pkg_dojar "azureus.jar" || die "dojar failed"

	java-pkg_dolauncher "${PN}" \
		--main "org.gudy.azureus2.ui.common.Main" \
		-pre "${FILESDIR}/${PN}-2.5.0.0-pre"      \
		--java_args '-Dazureus.install.path=${HOME}/.azureus/ ${JAVA_OPTIONS}' \
		--pkg_args '--ui=${UI}'

	doicon "${FILESDIR}/azureus.png"
	domenu "${FILESDIR}/azureus.desktop"

	use source && java-pkg_dosrc "${S}"/{com,edu,org}
}

pkg_postinst() {
	###
	### @Todo We should probably deactivate auto-update it by default,
	###       or even remove the option.
	###
	elog
	elog "It is not recommended to use Azureus auto-update feature,"
	elog "and it might not even work. You should disable auto-update,"
	elog "in \"Tools\" -> \"Options...\" -> \"Interface\" -> \"Start\"."
	elog

	elog
	elog "After running azureus for the first time, configuration"
	elog "options will be placed in \"~/.azureus/gentoo.config\"."
	elog "If you need to change some startup options, you should"
	elog "modify this file, rather than the startup script."
	elog
	elog "You can notably set the UI type \"console\", from this file."
	elog

	ewarn
	ewarn "If you are upgrading, and the menu in Azureus has entries"
	ewarn "like \"!MainWindow.menu.transfers!\" then you have a stray"
	ewarn "\"MessageBundle.properties\" file, and you may safely"
	ewarn "delete \"~/.azureus/MessagesBundle.properties\"."
	ewarn

	ewarn
	ewarn "Before azureus-2.5.0.0-r3, the Azureus plugin directory was"
	ewarn "set to \"~/plugins\", instead of \"~/.azureus/plugins\"."
	ewarn "If needed, you should move the plugins, to the new location."
	ewarn

	elog
	elog "If you have problems starting Azureus, try starting it"
	elog "from the command line to look at debugging output."
	elog

	ewarn
	ewarn "Running Azureus as root is not supported."
	ewarn

	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}
