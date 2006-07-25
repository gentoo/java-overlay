# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/azureus/azureus-2.3.0.6-r1.ebuild,v 1.1 2006/01/02 21:24:54 betelgeuse Exp $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Azureus - Java BitTorrent Client"
HOMEPAGE="http://azureus.sourceforge.net/"
SRC_URI="mirror://sourceforge/azureus/Azureus_${PV}_source.zip"
LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~x86"

IUSE="source"

RDEPEND=">=virtual/jre-1.4
	>dev-java/swt-3.2_pre1
	>=dev-java/log4j-1.2.8
	>=dev-java/commons-cli-1.0
	>=dev-java/bcprov-1.31
	!net-p2p/azureus-bin"
DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	>=dev-java/ant-core-1.6.2
	>=app-arch/unzip-5.0"

S=${WORKDIR}/${PN}

src_unpack() {
	mkdir ${S}
	cd ${S}
	unpack ${A}

	EPATCH_SUFFIX="patch" EPATCH_FORCE="yes" \
		epatch ${FILESDIR}/fedora/

	#removing osx files and entries
	rm -fr org/gudy/azureus2/ui/swt/osx org/gudy/azureus2/platform/macosx
	#removing windows files
	rm -fr org/gudy/azureus2/platform/win32
	#removing test files
	rm -fr org/gudy/azureus2/ui/swt/test
	rm -f org/gudy/azureus2/ui/console/multiuser/TestUserManager.java
	#removing bouncycastle
	rm -fr org/bouncycastle

	mkdir -p build/libs
	cd build/libs
	java-pkg_jar-from log4j
	java-pkg_jar-from commons-cli-1
	java-pkg_jar-from swt-3
	java-pkg_jar-from bcprov
}

src_compile() {
	# TODO test if this is still needed, and if so, use java-config --runtime
	# instead
	# Figure out correct boot classpath for IBM jdk.
	if [ ! -z "$(java-config --java-version | grep IBM)" ] ; then
		# IBM JRE
		ant_extra_opts="-Dbootclasspath=$(java-config --jdk-home)/jre/lib/core.jar:$(java-config --jdk-home)/jre/lib/xml.jar:$(java-config --jdk-home)/jre/lib/graphics.jar"
	fi

	use amd64 && ANT_OPTS="${ANT_OPTS} -Xmx1g"

	eant ${ant_extra_opts} jar
		
}

src_install() {
	java-pkg_dojar dist/Azureus2.jar || die "dojar failed"

	# copying the shell script to run the app
	newbin ${FILESDIR}/azureus-gentoo-${PV}-r1.sh azureus \
		|| die "Creating launcher failed."

	doicon "${FILESDIR}/azureus.png"
	domenu "${FILESDIR}/azureus.desktop"
	use source && java-pkg_dosrc ${S}/{com,org}
}

pkg_postinst() {
	echo
	einfo "Due to the nature of the portage system, we recommend"
	einfo "that users check portage for new versions of Azureus"
	einfo "instead of attempting to use the auto-update feature."
	einfo "You can disable auto-update in"
	einfo "Tools->Options...->Interface->Start"
	echo
	einfo "After running azureus for the first time, configuration"
	einfo "options will be placed in ~/.Azureus/gentoo.config"
	einfo "It is recommended that you modify this file rather than"
	einfo "the azureus startup script directly."
	echo
	einfo "As of this version, the new ui type 'console' is supported,"
	einfo "and this may be set in ~/.Azureus/gentoo.config."
	echo
	ewarn "If you are upgrading, and the menu in azureus has entries like"
	ewarn "\"!MainWindow.menu.transfers!\" then you have a stray"
	ewarn "MessageBundle.properties file,"
	ewarn "and you may safely delete ~/.Azureus/MessagesBundle.properties"
	echo
	einfo "It's recommended to use sun-java in version 1.5 or later."
	einfo "If you'll notice any problems running azureus and you've"
	einfo "got older java, try to upgrade it. Just remember not to set"
	einfo "a 1.5 jdk as the system jdk or things will break."
	echo
	ewarn "Please, do not run azureus as root!"
	ewarn "Azureus has not been developed for multi-user environments!"
}
