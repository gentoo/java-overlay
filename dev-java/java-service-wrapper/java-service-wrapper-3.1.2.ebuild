# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit base java-pkg

MY_PN=wrapper
MY_P="${MY_PN}_${PV}_src"
DESCRIPTION="The Wrapper makes it possible to install a Java Application as daemon." 
HOMEPAGE="http://wrapper.tanukisoftware.org/doc/english/introduction.html"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz"

LICENSE="java-service-wrapper"
SLOT="3.1"
KEYWORDS="~amd64 ~x86"
IUSE="jikes doc"

RDEPEND=">=virtual/jre-1.4
		dev-java/junit"

# TODO test with 1.3
DEPEND="${RDEPEND}
	>=virtual/jdk-1.4
	dev-java/ant
	jikes? ( dev-java/jikes )"
S="${WORKDIR}/${MY_P}"

# TODO file upstream
PATCHES="${FILESDIR}/${P}-gentoo.patch"

src_unpack() {
	unpack ${A}
	# renamed to avoid usage of stuff here"
	mv "${P}/tools" "${P}/tools-renamed-by-gentoo"
}

src_compile() {
	local antflags="main"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} jdoc -Djdoc.dir=api"

	CLASSPATH="$(java-pkg_getjars junit):${CLASSPATH}" \
		 ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_dojar lib/*.jar
	java-pkg_doso lib/*.so
	dobin bin/*

	dodoc doc/{AUTHORS,readme.txt,revisions.txt}

	use doc && java-pkg_dohtml -r doc/english/ api
}
