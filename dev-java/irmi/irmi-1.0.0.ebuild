# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="Intercepting RMI implementation for the Java platform"
HOMEPAGE="http://carol.objectweb.org/"
SRC_URI="http://gentooexperimental.org/distfiles/${P}.tar.bz2"
# cvs -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/carol login 
# cvs -z3 -d:pserver:anonymous@cvs.forge.objectweb.org:/cvsroot/carol export -r IRMI_1_0_0 irmi
# tar jcvf irmi-1.0.0.tar.bz2 irmi/

LICENSE="LGPL-2.1"
SLOT="1.0"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	jikes? (dev-java/jikes)"
RDEPEND=">=virtual/jre-1.4
	dev-java/commons-collections"
S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd ${S}

	cd ${S}/externals
	rm *.jar
	java-pkg_jar-from commons-collections
}

src_compile() {
	local antflags="jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} javadoc -Dbuild.doc=build/api"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar build/*.jar

	use doc && java-pkg_dohtml -r build/api
}
