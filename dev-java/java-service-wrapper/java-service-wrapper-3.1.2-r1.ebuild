# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit base java-pkg-2 java-ant-2

MY_PN=wrapper
MY_P="${MY_PN}_${PV}_src"
DESCRIPTION="The Wrapper makes it possible to install a Java Application as daemon." 
HOMEPAGE="http://wrapper.tanukisoftware.org/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz"

LICENSE="java-service-wrapper"
SLOT="3.1"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

RDEPEND=">=virtual/jre-1.4"

# TODO test with 1.3
DEPEND="${RDEPEND}
	>=virtual/jdk-1.4
	dev-java/ant
	test? ( dev-java/junit )"

S="${WORKDIR}/${MY_P}"

# Contains text relocations, should be fixed at some point
RESTRICT="stricter"

# TODO file upstream
PATCHES="${FILESDIR}/${P}-gentoo.patch"

src_unpack() {
	unpack ${A}
	cd ${S}
	# renamed to avoid usage of stuff here"
	mv tools tools-renamed-by-gentoo
}

src_compile() {
	eant jar $(use_doc -Djdoc.dir=api jdoc)	
}

src_test() {
	eant test	
}

src_install() {
	java-pkg_dojar lib/wrapper.jar
	java-pkg_doso lib/libwrapper.so
	dobin bin/wrapper

	dodoc doc/{AUTHORS,readme.txt,revisions.txt}

	use doc && java-pkg_dohtml -r doc/english/ api
	
	use source && java-pkg_dosrc src/java/*
}
