# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils
MY_PV=${PV%%_*}.b5.cvs20040118
MY_P=${PN}-${MY_PV}

DESCRIPTION="A small collection of hacks to make using Ant in an embedded envinronment much easier."
# This seems dead, but I don't have anywhere else to turn
HOMEPAGE="http://jakarta.apache.org/commons/sandbox/grant/"
SRC_URI="http://gentooexperimental.org/distfiles/${MY_P}.tar.gz"
DEPEND=">=virtual/jdk-1.3
	jikes? ( dev-java/jikes )
	dev-java/ant-core
	dev-java/junit"
RDEPEND=">=virtual/jre-1.3"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc jikes"
S=${WORKDIR}/${MY_P}

src_unpack(){
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo.diff
	mkdir -p target/lib
	cd target/lib
	java-pkg_jar-from junit
}

src_compile(){
	local antflags="jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"
	ant ${antflags} || die "compile failed"
}

src_install(){
	java-pkg_newjar target/${PN}-1.0-beta-4.jar ${PN}.jar
	use doc && java-pkg_dohtml -r dist/docs/api
}

src_test() {
	ant test || die "Test failed"
}
