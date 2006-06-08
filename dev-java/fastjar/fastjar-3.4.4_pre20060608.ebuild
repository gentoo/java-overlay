# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="http://dev.gentoo.org/~nichoj/distfiles/${P}.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${PN}"

src_install() {
	make install DESTDIR="${D}"
}
