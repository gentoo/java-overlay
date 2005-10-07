# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg

DESCRIPTION="Javac compatibility wrapper for the Eclipse Compiler for Java"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://gentooexperimental.org/distfiles/${P}.tar.bz2"
LICENSE="GPL-2"
KEYWORDS="~x86"
SLOT="0"

IUSE="doc jikes"

RDEPEND=">=virtual/jre-1.4
	=dev-java/eclipse-ecj-3.1*"

DEPEND="${RDEPEND}
	>=virtual/jdk-1.4
	dev-java/ant-core"

src_unpack() {
	unpack ${A}
	cd ${S}
	rm lib/*.jar
}

src_compile() {
	local antflags="jar -Dclasspath=$(java-pkg_getjars eclipse-ecj-3.1)"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "Failed to compile"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	dodoc README
	use doc && java-pkg_dohtml -r build/doc/api

	exeinto /usr/bin
	doexe bin/ecj-compat-3.1
}
