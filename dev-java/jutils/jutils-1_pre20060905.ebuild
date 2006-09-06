# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

#extracted from cvs on 20060905
#cvs -d :pserver:<login>@cvs.dev.java.net:/cvs login
#cvs -d :pserver:<login>@cvs.dev.java.net:/cvs export -r HEAD jutils

DESCRIPTION="An implementation of a set of APIs utilized by the Java Game
Technology Group."
HOMEPAGE="https://jutils.dev.java.net"
SRC_URI="http://www.counties.co.nz/alistair/distfiles/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/${PN}"

src_compile() {
	eant
}

src_install() {
	java-pkg_dojar ${WORKDIR}/jinput/coreAPI/lib/*.jar
}
