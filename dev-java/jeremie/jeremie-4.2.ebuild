# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="Jeremie provides an RMI-like programming style."
HOMEPAGE="http://jonathan.objectweb.org/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"
# cvs -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/jonathan login
# cvs -z3 -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/jonathan export -r JEREMIE_4_2 jeremie
# tar cjvf jeremie-4.2.tar.bz jeremie

LICENSE="LGPL-2.1"
SLOT="4"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND="virtual/jdk
	app-arch/unzip
	jikes? (dev-java/jikes)
	dev-java/ant-owanttask"
RDEPEND="virtual/jre
	=dev-java/jonathan-core-4*
	=dev-java/kilim-2*
	dev-java/monolog
	=dev-java/nanoxml-2.2*"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd ${S}

	cd externals
	rm *.jar
	java-pkg_jar-from jonathan-core-4
	java-pkg_jar-from kilim-1 kilim.jar
	java-pkg_jar-from monolog ow_monolog.jar
	java-pkg_jar-from nanoxml-2.2 nanoxml-lite.jar nanoxml-lite-2.2.1.jar
	
	# the jar from my ow-util-ant-tasks seems to slightly not work
	cd ../config
	rm *.jar
	java-pkg_jar-from ant-owanttask
}

src_compile() {
	local antflags="compile"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} jdoc -Doutput.dist.jdoc=output/dist/doc/api"

	# for some reason, we need to run ant twice to get the jar build
	ant ${antflags} || die "Compilation failed"
	ant jar || die "Compilation failed"
}

src_install() {
	java-pkg_dojar output/dist/lib/*.jar
	
	# TODO fix docs not being installed
	use doc & mv output/dist/doc/javadoc/user output/dist/doc/api && java-pkg_dohtml -r output/dist/doc/api
}
