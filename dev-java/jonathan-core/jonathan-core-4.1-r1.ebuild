# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN="${PN//-/}"
DESCRIPTION="Jonathan is a Distributed Object Platform (DOP) written entirely in Java."
HOMEPAGE="http://jonathan.objectweb.org/index.html"
SRC_URI="http://gentooexperimental.org/distfiles/${P}.tar.bz2"
# cvs -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/jonathan login
# cvs -z3 -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/jonathan export -r JONATHAN_CORE_4_1 jonathancore
# tar cjvf jonathan-core-4.1.tar.bz2 jonathancore

LICENSE="LGPL-2.1"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
	dev-java/nanoxml
	=dev-java/kilim-1*
	dev-java/monolog"
S=${WORKDIR}/${MY_PN}

src_unpack() {
	unpack ${A}
	cd ${S}

	cd config
	#rm *.jar
	java-pkg_jar-from kilim-1 kilim-tools.jar
	java-pkg_jar-from nanoxml nanoxml-lite.jar nanoxml-lite-2.2.1.jar
	# when we use the jar from this package, jar and jdoc targets break...
	#java-pkg_jar-from ow-util-ant-tasks

	cd ../externals
	rm *.jar
	java-pkg_jar-from kilim-1 kilim.jar
	java-pkg_jar-from monolog ow_monolog.jar
	java-pkg_jar-from ant-core ant.jar
}

src_compile() {
	eant jar $(use_doc  jdoc -Djdoc.dir=output/dist/api)
}

src_install() {
	java-pkg_dojar output/dist/lib/*.jar

	use doc && java-pkg_dohtml -r output/dist/api
}
