# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/azureus/azureus-2.3.0.4.ebuild,v 1.4 2005/11/24 23:04:16 betelgeuse Exp $

inherit eutils java-pkg

DESCRIPTION="Azureus - Java BitTorrent Client"
HOMEPAGE="http://azureus.sourceforge.net/"
SRC_URI="mirror://sourceforge/azureus/Azureus_${PV}_source.zip"
LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS="~ppc ~x86"

IUSE="source"

RDEPEND=">=virtual/jre-1.4
	>=dev-java/swt-3.0-r2
	>=dev-java/log4j-1.2.8
	>=dev-java/commons-cli-1.0
	dev-java/junit"
DEPEND=">=virtual/jdk-1.4
	${RDEPEND}
	>=dev-java/ant-core-1.6.2
	>=app-arch/unzip-5.0
	!net-p2p/azureus-bin"

S=${WORKDIR}/${PN}

src_unpack() {
	local PROGRAM_DIR="/usr/lib/${PN}"

	mkdir ${S} && cd ${S}
	unpack ${A}
#	cp ${FILESDIR}/build.xml ${S} || die "cp build.xml failed"

	#cp -f  ${FILESDIR}/SWTThread.java \
	#	${S}/org/gudy/azureus2/ui/swt/mainwindow/SWTThread.java \
	#	|| die "cp SWTThread.java failed!"

	#removing osx files and entries
	rm -fr org/gudy/azureus2/ui/swt/osx org/gudy/azureus2/ui/swt/test org/gudy/azureus2/platform/macosx/access

#	cp ${FILESDIR}/UpdaterPatcher.java ${S}/org/gudy/azureus2/update/ \
#		|| die "cp UpdaterPatrcher.java failed"

	mkdir -p build/libs
	cd build/libs
	java-pkg_jar-from log4j
	java-pkg_jar-from commons-cli-1
	java-pkg_jar-from swt-3
	java-pkg_jar-from junit
}

src_compile() {
	# Figure out correct boot classpath
	if [ ! -z "$(java-config --java-version | grep IBM)" ] ; then
		# IBM JRE
		ant_extra_opts="-Dbootclasspath=$(java-config --jdk-home)/jre/lib/core.jar:$(java-config --jdk-home)/jre/lib/xml.jar:$(java-config --jdk-home)/jre/lib/graphics.jar"
	fi

	# Fails to build on amd64 without this
	ANT_OPTS="${ANT_OPTS} -Xmx1g" \
		ant -q -q ${ant_extra_opts} jar -Dlibs.dir=\
		|| die "ant build failed"
}

src_install() {
	java-pkg_newjar dist/Azureus2.jar azureus.jar || die "doins jar failed"

	# copying the shell script to run the app
	newbin ${FILESDIR}/azureus-gentoo-${PV}.sh azureus \
		|| die "Creating launcher failed."

	doicon "${FILESDIR}/azureus.png"
	insinto /usr/share/applications
	doins "${FILESDIR}/azureus.desktop"
	use source && java-pkg_dosrc ${S}/{com,org}
}

pkg_postinst() {
	echo
	einfo "Due to the nature of the portage system, we recommend"
	einfo "that users check portage for new versions of Azureus"
	einfo "instead of attempting to use the auto-update feature."
	einfo "You can disable the upgrade warning in"
	einfo "View->Configuration->Interface->Start"
	echo
	einfo "After running azureus for the first time, configuration"
	einfo "options will be placed in ~/.Azureus/gentoo.config"
	einfo "It is recommended that you modify this file rather than"
	einfo "the azureus startup script directly."
	echo
	einfo "As of this version, the new ui type 'console' is supported,"
	einfo "and this may be set in ~/.Azureus/gentoo.config."
	echo
	ewarn "If you are upgrading, and the menu in azurues has entries like"
	ewarn "\"!MainWindow.menu.transfers!\" then you have a stray"
	ewarn "MessageBundle.properties file,"
	ewarn "and you may safely delete ~/.Azureus/MessagesBundle.properties"
	echo
	einfo "It's recommended to use sun-java in version 1.5 or later."
	einfo "If you'll notice any problems running azureus and you've"
	einfo "got older java, try to upgrade it"
	echo
	ewarn "Please, do not run azureus as root!"
	ewarn "Azureus has not been developed for multi-user environments!"
}
