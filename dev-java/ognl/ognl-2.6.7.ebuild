# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="Object-Graph Navigation Language; it is an expression language for getting and setting properties of Java objects"
HOMEPAGE="http://www.ognl.org/"
SRC_URI="http://www.ognl.org/${PV}/${P}-dist.zip"

LICENSE=""
SLOT="2.6"
KEYWORDS="~x86"
IUSE=""

DEPEND="virtual/jdk"
RDEPEND="virtual/jre"

src_compile() {
	einfo "This is only a place holder, as adependency of tapestry"
	die
}
