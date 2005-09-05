# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils
MY_PN=graph2
MY_PV=${PV%%_*}.cvs20040118
MY_P=${MY_PN}-${MY_PV}
DESCRIPTION="A toolkit for managing graphs and graph based data structures"
# This is borked, but I don't have anywhere else to turn
HOMEPAGE="http://jakarta.apache.org/commons/sandbox/graph/"
# this was extracted from a source rpm at jpackage... maybe I'll use it directly
# at some point
SRC_URI="mirror://gentoo/distfiles/${MY_P}.tar.gz"
LDEPEND="dev-java/log4j
	dev-java/commons-collections
	dev-java/junit
	dev-java/jdepend
	dev-java/xerces"
DEPEND=">=virtual/jdk-1.3
	jikes? ( dev-java/jikes )
	dev-java/ant-core
	${LDEPEND}"
RDEPEND=">=virtual/jdk-1.3
	${LDEPEND}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc jikes "
S=${WORKDIR}/${MY_P}

src_unpack(){
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo.diff
	mkdir -p target/lib
	cd target/lib
	java-pkg_jar-from log4j
	java-pkg_jar-from commons-collections
	java-pkg_jar-from jdepend
	java-pkg_jar-from junit
	java-pkg_jar-from xerces-2 xml-apis.jar

}

src_compile(){
	local antflags="jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"
	ant ${antflags} || die "compile failed"
}

src_install(){
	java-pkg_dojar target/commons-graph*.jar
	use doc && java-pkg_dohtml -r dist/docs/api
}

src_test() {
	ant test || die "test failed"	
}
