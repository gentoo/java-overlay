# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit base java-pkg

MY_PN=wrapper
MY_P="${MY_PN}_${PV}_src"
DESCRIPTION=" The Wrapper makes it possible to install a Java Application as a Windows NT Service. The scripts provided with the Wrapper also make it very easy to install those same Java Applications as daemon processes on UNIX systems."
HOMEPAGE="http://wrapper.tanukisoftware.org/doc/english/introduction.html"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz"

LICENSE="java-service-wrapper"
SLOT="3.1"
KEYWORDS="~amd64 ~x86"
IUSE="jikes doc"

# TODO test with 1.3
DEPEND=">=virtual/jdk-1.4
	dev-java/ant
	jikes? (dev-java/jikes)"
RDEPEND=">=virtual/jre-1.4"
S="${WORKDIR}/${MY_P}"

# TODO file upstream
PATCHES="${FILESDIR}/${P}-gentoo.patch"

src_compile() {
	local antflags="main"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} jdoc -Djdoc.dir=api"

	ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_dojar lib/*.jar
	java-pkg_doso lib/*.so
	dobin bin/*

	dodoc doc/{AUTHORS,readme.txt,revisions.txt}

	use doc && java-pkg_dohtml -r doc/english/ api
}
