# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Utility for automatically generating javadoc-style documentation for JavaServer Pages Technology Tag Libraries"
HOMEPAGE="https://taglibrarydoc.dev.java.net/"
SRC_URI="http://www.counties.co.nz/alistair/distfiles/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		dev-java/javacc"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack "${A}"
	cd "${S}"	
	epatch "${FILESDIR}/build.xml.patch"
}

src_compile() {
	eant -DJAVACC_HOME=$(java-pkg_getjars javacc) dist
}

src_install() {
	java-pkg_dojar "dist/taglibrarydoc-1_3/tlddoc.jar"

	java-pkg_dolauncher
}
