# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="doc examples source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="open source library of high-quality Java components"
HOMEPAGE="http://flib.sourceforge.net/"
MY_PN=FLib
MY_P=${MY_PN}-${PV}
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"

S=${WORKDIR}/${MY_PN}

EANT_BUILD_TARGET="all"

src_install() {
	java-pkg_dojar */build/*.jar
	dodoc NOTES.txt || die
	# has javadocs if use doc but not otherwise
	java-pkg_dohtml -r . || die
	use source && java-pkg_dosrc */org
}
