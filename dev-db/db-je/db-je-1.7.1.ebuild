# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_PN=${PN##db-}
MY_P=${MY_PN}-${PV}
DESCRIPTION="Berkeley DB JE is a high performance, transactional storage engine written entirely in Java"
HOMEPAGE="http://sleepycat.com/products/je.shtml"
SRC_URI="http://downloads.sleepycat.com/${MY_P}.tar.gz"

LICENSE="Sleepycat"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="jikes doc"

DEPEND="=virtual/jdk-1.4*
	dev-java/ant
	jikes? ( dev-java/jikes )"
RDEPEND="=virtual/jre-1.4*"
S=${WORKDIR}/${MY_P}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} -Ddoc.dir=./docs/api javadoc-all"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"

	ant ${antflags} || die "Compile failed"
}

src_install() {
	java-pkg_dojar build/lib/je.jar
	dodoc README

	use doc && java-pkg_dohtml -r docs/api
}
