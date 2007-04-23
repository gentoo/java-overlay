# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Jar Bundler Ant Task"
HOMEPAGE="http://www.loomcom.com/jarbundler/"
SRC_URI="http://www.loomcom.com/${PN}/dist/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
		 dev-java/ant-core"

src_unpack() {
	unpack "${A}"
	cd "${S}"
	mkdir lib
	cd lib
	java-pkg_jarfrom ant-core ant.jar
}

src_compile() {
	eant jar
}

src_install() {
	java-pkg_newjar "bin/${P}.jar"
	use doc && dodoc README.TXT
}
