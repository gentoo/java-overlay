# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

DESCRIPTION="Goal-oriented process framework"
HOMEPAGE="http://werkz.sourceforge.net/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"
# cvs -d :pserver:anonymous@cvs.werkz.codehaus.org:/home/projects/werkz/scm login
# cvs -z3 -d :pserver:anonymous@cvs.werkz.codehaus.org:/home/projects/werkz/scm export -r WERKZ_MAVEN_1_0-BRANCH werkz
# tar cjvf werkz-1.0_beta4.tar.bz2 werkz
LICENSE="Werken"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"

LDEPEND="dev-java/commons-logging
	=dev-java/commons-jelly-1*
	=dev-java/commons-jelly-tags-ant-1.0*"
DEPEND="virtual/jdk
	dev-java/ant-core
	dev-java/junit
	${LDEPEND}"
RDEPEND="virtual/jre
	${LDEPEND}"
S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo.patch

	mkdir -p ${S}/lib
	cd ${S}/lib
	java-pkg_jar-from commons-logging
	java-pkg_jar-from commons-jelly-1
	java-pkg_jar-from commons-jelly-tags-ant-1.0
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} -Djavadocdir=target/docs/api javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"

	ant ${antflags} || die "Compile failed"
}

src_install() {
	java-pkg_newjar target/${PN}*.jar ${PN}.jar
	use doc && java-pkg_dohtml -r target/docs/api
}


src_test() {
	ant test || die "Test failed"
}
