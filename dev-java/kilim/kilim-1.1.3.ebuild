# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_PN=Kilim
DESCRIPTION="Kilim is a generic configuration framework based on the concept of configuration by software assembly.Kilim is a generic configuration framework based on the concept of configuration by software assembly."
HOMEPAGE="http://kilim.objectweb.org/"
SRC_URI="http://download.forge.objectweb.org/${PN}/${MY_PN}_${PV//./_}-src.tar.gz"

LICENSE="LGPL-2.1"
SLOT="1"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND="virtual/jdk
	dev-java/ant-core
	jikes? (dev-java/jikes)"
RDEPEND="virtual/jre
	=dev-java/nanoxml-2.2*"
S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd ${S}
	
	cd externals
	rm *.jar
	java-pkg_jar-from nanoxml-2.2 nanoxml-lite.jar
}

src_compile() {
	local antflags="jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes "
	use doc && antflags="${antflags} javadoc -Djavadoc.home=doc/api" 

	ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_dojar distrib/*.jar
	use doc && java-pkg_dohtml -r doc/api
	dodoc Readme.txt
}
