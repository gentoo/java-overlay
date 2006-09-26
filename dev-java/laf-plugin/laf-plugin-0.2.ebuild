# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A generic plugin framework for look-and-feels"
HOMEPAGE="https://laf-plugin.dev.java.net/"
SRC_URI="http://www.counties.co.nz/alistair/distfiles/${PN}-src-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/${PN}-src"

src_unpack() {
	unpack ${A}
	cd ${S}
	cp ${FILESDIR}/build.xml .
	mkdir src
	mv org src/
}

src_compile() {
	eant
}

src_install() {
	java-pkg_dojar dist/*.jar
}
