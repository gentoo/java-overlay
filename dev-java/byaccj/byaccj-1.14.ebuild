# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A java extension of BSD YACC-compatible parser generator"
HOMEPAGE="http://byaccj.sourceforge.net/"
MY_P="${PN}${PV}_src"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
LICENSE="as-is"
SLOT="0"
KEYWORDS="-*"
IUSE=""
DEPEND=""
RDEPEND=""

S=${WORKDIR}/${MY_P}

src_compile() {
	make -C src linux || die "failed too build"
}

src_install() {
	newbin src/yacc.linux ${PN}  || die "missing bin"
	#newman src/yacc.1 ${PN}.1 // would need to rewrite the not talk about yacc
	dodoc docs/ACKNOWLEDGEMEN || die
}
