# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/jsynthlib/jsynthlib-0.19_pre20041220.ebuild,v 1.3 2006/03/08 15:38:05 flameeyes Exp $

inherit java-pkg-2

DESCRIPTION="Java-based MIDI hardware SysEx librarian"
HOMEPAGE="http://www.jsynthlib.org/"
SRC_URI="http://www.jsynthlib.org/JSynthLib-${PV}.jar"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	dev-java/groovy"
RDEPEND=">=virtual/jre-1.4
	dev-java/groovy"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cd ${S}
	java-pkg_jar-from groovy-1
	make clean
}

src_compile() {
	while test ! -e ${PN}.jar; do
		make jar
	done
}

src_install() {
	java-pkg_dojar ${PN}.jar
	java-pkg_dolauncher ${PN} --main JSynthLib
}
