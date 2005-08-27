# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="A Java-based services and configuration microkernel"
HOMEPAGE="http://jakarta.apache.org/hivemind/"
SRC_URI="mirror://apache/jakarta/${PN}/${P}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="virtual/jdk"
RDEPEND="virtual/jre
	=dev-java/ognl-2.6*"

src_compile() {
	einfo "This is only a place holder, a dependency of tapestry"
	die
}
