# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-pkg-2 java-ant-2

DESCRIPTION="Intercepting RMI implementation for the Java platform"
HOMEPAGE="http://carol.objectweb.org/"
SRC_URI="http://dev.gentoo.org/~nichoj/distfiles/${P}.tar.bz2"
# cvs -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/carol login 
# cvs -z3 -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/carol export -r IRMI_1_0_0 irmi
# tar jcvf irmi-1.0.0.tar.bz2 irmi/

LICENSE="LGPL-2.1"
SLOT="1.0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
	dev-java/commons-collections"
S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd ${S}

	cd ${S}/externals
	rm *.jar
	java-pkg_jar-from commons-collections
	java-pkg_jar-from --build-only junit
}

src_compile() {
	eant jar $(use_doc javadoc -Dbuild.doc=build/api)
}

src_install() {
	java-pkg_dojar build/*.jar

	use doc && java-pkg_dohtml -r build/api
}
