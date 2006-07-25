# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

MY_P="${P}-src"
DESCRIPTION="CAROL is a library allowing to use different RMI implementations."
HOMEPAGE="http://carol.objectweb.org/"
SRC_URI="http://download.fr2.forge.objectweb.org/${PN}/${MY_P}.tgz"

LICENSE="LGPL-2.1"
SLOT="2.0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
	dev-java/commons-collections
	dev-java/commons-logging
	=dev-java/irmi-1.0*
	=dev-java/jacorb-2.2*
	=dev-java/mx4j-3.0*
	dev-java/velocity
	dev-java/jgroups"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd ${S}
	
	epatch ${FILESDIR}/${P}-jikes.patch
	cd externals
	rm *.jar
	java-pkg_jar-from commons-collections
	java-pkg_jar-from commons-logging commons-logging-api.jar
	java-pkg_jar-from irmi-1.0
	java-pkg_jar-from jacorb-2.2 jacorb.jar
	java-pkg_jar-from mx4j-3.0 mx4j.jar
	java-pkg_jar-from velocity
	java-pkg_jar-from jgroups jgroups-core.jar
}

src_compile() {
	eant jar $(use_doc jdoc -Ddist.jdoc=output/dist/api)
	

	# This is provided by irmi... TODO patch this
	rm output/dist/lib/irmi.jar
}

src_install() {
	java-pkg_dojar output/dist/lib/*.jar

	use doc && java-pkg_dohtml -r output/dist/api
}
