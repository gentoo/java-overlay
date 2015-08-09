# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="source"
inherit base java-pkg-2

DESCRIPTION="Pub-sub event broadcasting mechanism"
HOMEPAGE="https://eventbus.dev.java.net/"
SRC_URI="https://eventbus.dev.java.net/files/documents/4303/135896/${P}-sources.jar"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

S="${WORKDIR}"

src_compile() {
	mkdir -p build || die
	ejavac -d build $(find org -name '*.java')
	$(java-config -j) cf "${PN}.jar" -C build org || die
}

src_install() {
	java-pkg_dojar "${PN}.jar"
	use source && java-pkg_dosrc org
}
