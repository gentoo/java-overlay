# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


inherit java-pkg

MY_P=${P/t/T}
DESCRIPTION="An open-source framework for creating dynamic, robust, highly scalable web applications in Java."
HOMEPAGE="http://jakarta.apache.org/tapestry/"
SRC_URI="mirror://apache/jakarta/${PN}/${MY_P}-bin.tar.gz mirror://apache/jakarta/${PN}/${MY_P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="3"
KEYWORDS="~x86"
IUSE=""

DEPEND="virtual/jdk"
RDEPEND="virtual/jre
	=dev-java/ognl-2.6*"

src_compile() {
	einfo "This is only a place holder, till dependencies can be filled"
	die
}
