# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
MY_P="${PN}-r${PV}"
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="A collection of Google's core Java libraries"
HOMEPAGE="http://code.google.com/p/guava-libraries/"
SRC_URI="http://guava-libraries.googlecode.com/files/${MY_P}.zip"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/jsr305"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.5"

DEPEND="${CDEPEND}
	app-arch/unzip
	>=virtual/jdk-1.5"

S="${WORKDIR}/${MY_P}"
JAVA_GENTOO_CLASSPATH="jsr305"

src_prepare() {
	unpack "./${PN}-src-r${PV}.zip"
}

src_install() {
	java-pkg-simple_src_install
	dodoc README || die
}
