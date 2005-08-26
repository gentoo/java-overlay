# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg

MY_PN=${PN##*-}

DESCRIPTION="Eclipse Compiler for Java"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://www.scorec.rpi.edu/~nichoj/projects/java/${P}-gentoo-r1.tar.bz2"
LICENSE="EPL-1.0"
KEYWORDS="~x86"
SLOT="3.1"

IUSE="doc jikes"

RDEPEND=">=virtual/jre-1.4"

DEPEND="${RDEPEND}
	>=virtual/jdk-1.4
	dev-java/ant-core"

src_unpack() {
	unpack ${A}
	cd ${S}
#	epatch ${FILESDIR}/${P}-build_xml.patch
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "Failed to compile ecj.jar"
}

src_install() {
	java-pkg_dojar build/${MY_PN}.jar || die "ecj.jar not installable"

	dodoc README
	use doc && java-pkg_dohtml -r build/doc/api

	exeinto /usr/bin
	doexe ${MY_PN}-${SLOT}
}

