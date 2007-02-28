# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="A jar program written in C"
HOMEPAGE="http://fastjar.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"

IUSE=""

RDEPEND=""
DEPEND=""

src_install() {
	emake DESTDIR=${D} install || die "make install failed"
	dodoc AUTHORS CHANGES NEWS README || die
}
