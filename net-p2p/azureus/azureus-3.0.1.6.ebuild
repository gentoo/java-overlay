# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/azureus/azureus-2.5.0.4-r1.ebuild,v 1.5 2007/06/14 00:41:43 angelos Exp $

# issues:
# the new vuze gui requires swt built with embedded mozilla support, or azureus will hang at startup
# however, you can still start the old GUI which doesn't require it, by using file/restart
# (which is kind of bug, and maybe I should put that patch, that removes restart from menu, back)
# probably could be invoked also by using different Main class (look for them there are plenty :)
# so we could have some old-gui flag which would run that one and remove the mozilla dep
# best would be some per-user setting and startup script check for swt mozilla support and die...
# also the swt/console choosing doesn't work anymore, the class that was used to run is not there
# and the whole console GUI with its log4j and commons-cli dependencies is gone from the sources
# but it's found in upstream jar, lovely. Would need to use some cvs checkout :(

JAVA_PKG_IUSE="source"

inherit eutils fdo-mime java-pkg-2 java-ant-2

DESCRIPTION="Azureus - Java BitTorrent Client"
HOMEPAGE="http://azureus.sourceforge.net/"
SRC_URI="mirror://sourceforge/azureus/Azureus_${PV}_source.zip"
LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND="
	>=virtual/jre-1.4
	>=dev-java/swt-3.3_pre3
	>=dev-java/bcprov-1.35
	!net-p2p/azureus-bin"
#	>=dev-java/log4j-1.2.8
#	>=dev-java/commons-cli-1.0
DEPEND="${RDEPEND}
	>=virtual/jdk-1.4
	dev-util/desktop-file-utils
	app-arch/unzip"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}

	EPATCH_SUFFIX="patch" EPATCH_FORCE="yes" \
		epatch ${FILESDIR}/patches-${PV}/

	epatch ${FILESDIR}/azureus-bcprov-1.35.patch

	#removing osx files and entries
	rm -fr org/gudy/azureus2/ui/swt/osx org/gudy/azureus2/platform/macosx || die
	#removing windows files
	rm -fr org/gudy/azureus2/ui/swt/win32 org/gudy/azureus2/platform/win32 \
		com/aelitis/azureus/util/win32 || die
	#removing test files
	rm -fr org/gudy/azureus2/ui/swt/test || die
	#removing bouncycastle
	rm -fr org/bouncycastle || die

	mkdir -p build/libs
	cd build/libs
#	java-pkg_jar-from log4j
#	java-pkg_jar-from commons-cli-1
	java-pkg_jar-from swt-3
	java-pkg_jar-from bcprov
}

src_compile() {
	# we started to force ecj because -Xmx seemed to have no effect but that
	# was because of ANT_OPTS not exported. Bug #145338
	use x86 && export ANT_OPTS="-Xmx128m"
	use amd64 && export ANT_OPTS="-Xmx256m"

	eant ${ant_extra_opts} jar
}

src_install() {
	java-pkg_dojar dist/Azureus2.jar || die "dojar failed"


	java-pkg_dolauncher ${PN} \
		--main com.aelitis.azureus.ui.swt.Initializer \
		-pre ${FILESDIR}/${PN}-3-pre \
		--java_args '-Dazureus.install.path=${HOME}/.azureus/ ${JAVA_OPTIONS}'
#		--pkg_args '--ui=${UI}' \

	doicon "${FILESDIR}/azureus.png"
	domenu "${FILESDIR}/azureus.desktop"
	use source && java-pkg_dosrc ${S}/{com,org}
}

pkg_postinst() {
	if ! built_with_use --missing false -o dev-java/swt firefox seamonkey xulrunner; then
		ewarn "dev-java/swt must be compiled with the firefox, seamonkey or xulrunner USE flag"
		ewarn "(support may vary per swt version) or azureus will hang at startup!"
	fi

	echo
	elog "Due to the nature of the portage system, we recommend"
	elog "that users check portage for new versions of Azureus"
	elog "instead of attempting to use the auto-update feature."
	elog "We also set azureus.install.path to ~/.azureus so auto"
	elog "update probably does not even work."
	elog ""
	elog "You can disable auto-update in"
	elog "Tools->Options...->Interface->Start"
	echo
	elog "After running azureus for the first time, configuration"
	elog "options will be placed in ~/.azureus/gentoo.config"
	elog "It is recommended that you modify this file rather than"
	elog "the azureus startup script directly."
	echo
	elog "As of this version, the new ui type 'console' is supported,"
	elog "and this may be set in ~/.azureus/gentoo.config."
	echo
	elog "If you have problems starting azureus, try starting it"
	elog "from the command line to look at debugging output."
	echo
	ewarn "If you are upgrading, and the menu in azureus has entries like"
	ewarn "\"!MainWindow.menu.transfers!\" then you have a stray"
	ewarn "MessageBundle.properties file,"
	ewarn "and you may safely delete ~/.azureus/MessagesBundle.properties"
	echo
	elog "It's recommended to use Sun's Java version 1.5 or later."
	elog "If you're experiencing problems running azureus and you've"
	elog "using an older version of Java, try to upgrading to a new version. "
	echo
	elog "New in 2.5.0.0-r3:"
	ewarn 'azureus.install.path was changed to ${HOME}/.azureus/. Before'
	ewarn 'the Azureus plugin dir was created to the current working directory.'
	ewarn 'This means that you probably have a useless plugins directory in'
	ewarn 'your home directory.'
	ewarn 'See http://bugs.gentoo.org/show_bug.cgi?id=145908'
	ewarn 'for more information. Also you probably need to move the user'
	ewarn 'installed plugins to the new plugin directory.'
	echo
	ewarn "Please, do not run azureus as root!"
	ewarn "Azureus has not been developed for multi-user environments!"

	fdo-mime_desktop_database_update
}

pkg_prerm() {
	fdo-mime_desktop_database_update
}
