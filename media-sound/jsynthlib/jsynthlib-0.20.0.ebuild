# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-pkg-2

DESCRIPTION="Java-based MIDI hardware SysEx librarian"
HOMEPAGE="http://www.jsynthlib.org/"
SRC_URI="http://www.jsynthlib.org/JSynthLib-${PV}.jar"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
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
