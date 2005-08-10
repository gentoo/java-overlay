# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_P="${PN}_${PV}_src"
DESCRIPTION=" The Wrapper makes it possible to install a Java Application as a Windows NT Service. The scripts provided with the Wrapper also make it very easy to install those same Java Applications as daemon processes on UNIX systems."
HOMEPAGE="http://wrapper.tanukisoftware.org/doc/english/introduction.html"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="java-service-wrapper"
SLOT="3.1"
KEYWORDS="~x86"
IUSE="jikes doc"

DEPEND="virtual/jdk
	dev-java/ant
	jikes? (dev-java/jikes)"
RDEPEND="virtual/jre"
S="${WORKDIR}/${MY_P}"

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
