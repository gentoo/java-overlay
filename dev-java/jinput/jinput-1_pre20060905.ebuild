# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="Jinput is an implementation of an API for game controller discovery and polled input"
HOMEPAGE="https://jinput.dev.java.net"
SRC_URI="http://www.counties.co.nz/alistair/distfiles/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.4
		dev-java/jutils
		>=dev-java/ant-core-1.5*
		dev-java/ant-tasks"
RDEPEND=">=virtual/jre-1.4
		${DEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}
	cd ${WORKDIR}
	epatch "${FILESDIR}/jinput-fix-build.xmls.patch"
	#epatch "${FILESDIR}/remove-jutils-from-jinput.patch"
	cd ${S}/coreAPI
	mkdir lib
	cd lib
	java-pkg_jarfrom jutils
}

src_compile() {
	eant
}

src_install() {
	java-pkg_dojar dist/jinput.jar
	java-pkg_doso dist/*.so
}

src_test() {
	eant texttest
}
