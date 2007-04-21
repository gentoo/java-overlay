# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="A wrapper for some of Sun's Java Look and Feels to enable anti-aliasing."
HOMEPAGE="http://smoothmetal.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86"
JAVA_PKG_IUSE="doc source"
IUSE=""
EANT_BUILD_TARGET="dist"
S=${WORKDIR}

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"

src_unpack() {
	unpack ${A}
	cd ${S}
	rm -rf dist
	rm -rf docs
}

src_install() {
	java-pkg_dojar dist/smoothmetal.jar
	use doc && java-pkg_dohtml -r docs/api
	use source && java-pkg_dosrc src/*
}
