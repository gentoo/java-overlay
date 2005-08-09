# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_PN="Monolog"
MY_P="${MY_PN}_${PV}_src"
DESCRIPTION="The goal of Monolog is to define and maintain the ObjectWeb API for the logging."
HOMEPAGE="http://monolog.objectweb.org/"
SRC_URI="http://download.forge.objectweb.org/${PN}/${MY_P}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="jikes"

DEPEND="virtual/jdk
	dev-java/ant
	jikes? (dev-java/jikes)
	app-arch/unzip"
RDEPEND="virtual/jre
	dev-java/log4j
	dev-java/p6spy
	=dev-java/velocity-1*"

src_unpack() {
	mkdir -p ${S}
	cd ${S}
	unpack ${A}


	cd externals
	rm *.jar
	java-pkg_jar-from log4j,p6spy,velocity-1
}

src_compile() {
	local antflags="clean jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"

	ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_dojar output/dist/lib/*.jar
}
