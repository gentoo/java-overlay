# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/qdox/qdox-20050104.ebuild,v 1.4 2005/05/04 20:05:58 luckyduck Exp $

inherit java-pkg

DESCRIPTION="Parser for extracting class/interface/method definitions from source files with JavaDoc tags."
HOMEPAGE="http://qdox.codehaus.org"
# Used jpackage's source rpm as a guide
# tarball is a cvs checkout of 1.4, plus a few source files, and a patch
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="Apache-1.1"
SLOT="1.4"
KEYWORDS="~x86"
IUSE="doc jikes source"

DEPEND=">=virtual/jdk-1.4
	jikes? ( >=dev-java/jikes-1.21 )
	>=dev-java/ant-core-1.4
	=dev-java/jmock-1.0*
	dev-java/mockobjects
	dev-java/junit"
RDEPEND=">=virtual/jre-1.4"

src_compile() {
	local antflags="jar -lib $(java-pkg_getjars jmock-1.0,mockobjects,junit)"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "failed to build"
}

src_install() {
	java-pkg_newjar target/${P}.jar ${PN}.jar
	dodoc README.txt

	use doc	&& java-pkg_dohtml -r dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
