# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="http://tonicsystems.com/products/jarjar/"
HOMEPAGE="http://tonicsystems.com/products/jarjar/"
SRC_URI="mirror://sourceforge/${PN}/${P}.jar"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="virtual/jdk"
RDEPEND="virtual/jre"

src_unpack() {
	ewarn "This is a binary release until the source can be acquired."
}

src_install() {
	java-pkg_newjar ${DISTDIR}/${A} ${PN}.jar
}
