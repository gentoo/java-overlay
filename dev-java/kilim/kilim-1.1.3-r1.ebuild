# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN=Kilim
DESCRIPTION="Kilim is a generic configuration framework based on the concept of configuration by software assembly.Kilim is a generic configuration framework based on the concept of configuration by software assembly."
HOMEPAGE="http://kilim.objectweb.org/"
SRC_URI="http://download.forge.objectweb.org/${PN}/${MY_PN}_${PV//./_}-src.tar.gz"

LICENSE="LGPL-2.1"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.3
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.3
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
	eant jar $(use_doc javadoc -Djavadoc.home=doc/api)
}

src_install() {
	java-pkg_dojar distrib/*.jar
	use doc && java-pkg_dohtml -r doc/api
	dodoc Readme.txt
}
