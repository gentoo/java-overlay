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
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND="virtual/jdk
	app-arch/unzip
	jikes? (dev-java/jikes)
	dev-java/ow-util-ant-tasks"
RDEPEND="virtual/jre
	dev-java/jonathan-core
	=dev-java/kilim-2*
	dev-java/monolog
	dev-java/nanoxml"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd ${S}

	cd externals
	rm *.jar
	java-pkg_jar-from jonathan-core
	java-pkg_jar-from kilim-1 kilim.jar
	java-pkg_jar-from monolog ow_monolog.jar
	java-pkg_jar-from nanoxml nanoxml-lite.jar nanoxml-lite-2.2.1.jar
	
	# the jar from my ow-util-ant-tasks seems to slightly not work
#	cd ../config
#	rm *.jar
#	java-pkg_jar-from ow-util-ant-tasks
}

src_compile() {
	local antflags="-Dproject.name=${PN} jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} jdoc -Doutput.dist.jdoc=output/dist/doc/api"

	ant ${antflags} || die "Compilation failed"
}

# TODO fix docs not being installed
src_install() {
	java-pkg_dojar output/dist/lib/*.jar
	
	use doc & mv output/dist/doc/javadoc/user output/dist/doc/api && java-pkg_dohtml -r output/dist/doc/api
}
