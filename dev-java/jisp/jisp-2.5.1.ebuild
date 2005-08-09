# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="Java Indexed Serialization Package: A small, embedded database engine written in Pure Java"
HOMEPAGE="http://www.coyotegulch.com/products/jisp/"
SRC_URI="mirror://gentoo/${P}-source.tar.gz"

LICENSE="SVFL"
SLOT="2.5"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND="virtual/jdk
	jikes? (dev-java/jikes)"
RDEPEND="virtual/jre"

src_unpack() {
	unpack ${A}
	cd ${S}
	mkdir src
	mv com src
	cp ${FILESDIR}/build-${PVR}.xml build.xml
}

src_compile() {
	local antflags="jar -Dproject.name=${PN}"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc"

	ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
}
