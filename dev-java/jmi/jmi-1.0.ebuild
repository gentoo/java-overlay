# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="Java Metadata Interface"

HOMEPAGE="http://java.sun.com/products/jmi/"

SRC_URI="jmi.jar"

LICENSE="as-is"

SLOT="0"

KEYWORDS="~x86"

IUSE=""

DEPEND=""

src_unpack() {
	mkdir ${S}
	cp ${DISTDIR}/jmi.jar ${S}
}
 
src_compile() {
	einfo "Binary ebuild"
}

src_install() {
	dodoc ${FILESDIR}/jmi-license.txt
	dojar jmi.jar
}
