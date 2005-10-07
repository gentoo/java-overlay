# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit java-pkg

MY_PV="20050706"
MY_P="${PN}-${MY_PV}"
DESCRIPTION="Javassist makes Java bytecode manipulation simple."
SRC_URI="http://gentooexperimental.org/distfiles/${MY_P}.tar.bz2"
HOMEPAGE="http://www.csg.is.titech.ac.jp/~chiba/javassist/"

LICENSE="MPL-1.1"
SLOT="3.1"
KEYWORDS="x86 amd64 ~ppc"
IUSE="doc jikes source"

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		>=dev-java/ant-core-1.5
		jikes? ( dev-java/jikes )
		source? ( app-arch/zip )"
S="${WORKDIR}/${PN}"

src_compile() {
	local antflags="clean jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadocs"
	ant ${antflags} || die "failed to build"
	mv html api
}

# TODO check the docs that are installed
src_install() {
	java-pkg_dojar ${PN}.jar
	java-pkg_dohtml Readme.html
	use doc && java-pkg_dohtml -r api
	use source && java-pkg_dosrc src/main/javassist
}
