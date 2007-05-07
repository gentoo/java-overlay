# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_ANT_TASKS="ant-nodeps"
JAVA_PKG_IUSE="doc source test"
inherit base java-pkg-2 java-ant-2 eutils

MY_PN=wrapper
MY_P="${MY_PN}_${PV}_src"
DESCRIPTION="A wrapper that makes it possible to install a Java Application as daemon."
HOMEPAGE="http://wrapper.tanukisoftware.org/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_P}.tar.gz"

LICENSE="java-service-wrapper"
SLOT="3.1"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.4"

# TODO test with 1.3
DEPEND="${RDEPEND}
	>=virtual/jdk-1.4
	test? (
		dev-java/ant-junit
		=dev-java/junit-3*
	)"

S="${WORKDIR}/${MY_P}"

# Contains text relocations, should be fixed at some point
RESTRICT="stricter"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# TODO file upstream	
	epatch ${FILESDIR}/${P}-gentoo.patch
	epatch ${FILESDIR}/${P}-buildxml.patch

	# renamed to avoid usage of stuff here"
	mv tools tools-renamed-by-gentoo

	if use test; then
		mkdir lib
		cd lib
		java-pkg_jar-from --build-only junit
	fi
}

src_compile() {
	eant jar $(use_doc -Djdoc.dir=api jdoc)
}

src_test() {
	ANT_TASKS="ant-junit ant-nodeps" eant test
}

src_install() {
	java-pkg_dojar lib/wrapper.jar
	java-pkg_doso lib/libwrapper.so
	dobin bin/wrapper

	dodoc doc/{AUTHORS,readme.txt,revisions.txt}

	use doc && java-pkg_dohtml -r doc/english/ api

	use source && java-pkg_dosrc src/java/*
}
