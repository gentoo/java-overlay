# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Maven repository for Gentoo"
HOMEPAGE=""
SRC_URI="http://dev.gentoo.org/~nichoj/maven/${PF}.tar.bz2"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

S="${WORKDIR}/${PN}"

src_install() {
	dodir /usr/share/maven-gentoo-repo
	cp -r * ${D}/usr/share/maven-gentoo-repo
}
