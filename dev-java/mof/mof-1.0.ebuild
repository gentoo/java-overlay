# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="Meta Object Facility"

HOMEPAGE="http://www.omg.org/"

SRC_URI="mof.jar"

LICENSE="as-is"

SLOT="0"

KEYWORDS="~x86"

IUSE=""

DEPEND=""

RDEPEND="virtual/jre"

src_unpack() {
	mkdir ${S}
	cp ${DISTDIR}/mof.jar ${S}
}
 
src_compile() {
	einfo "Binary ebuild"
}

src_install() {
	dodoc ${FILESDIR}/mof-license.txt
	dojar mof.jar
}
