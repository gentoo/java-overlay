# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A java extension of BSD YACC-compatible parser generator"

HOMEPAGE="http://byaccj.sourceforge.net/"
SRC_URI="mirror://gentoo/${PN}${PV}.tar.gz"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
DEPEND=""

S=${WORKDIR}/${PN}${PV}

src_unpack() {
	unpack ${A}
	cd ${S}
	rm -f yacc*
}

src_compile() {
	cd src
	make linux || die "failed too build"
}

src_install() {
	newbin src/yacc.linux byaccj || die "missing bin"
}
