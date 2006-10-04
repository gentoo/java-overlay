# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# does not need java-ant-2, source and target is already set to 1.4
inherit java-pkg-2

DESCRIPTION="Swing components for date operations and palettes"
HOMEPAGE="http://${PN}.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-full.zip"
LICENSE="BSD"
KEYWORDS="~x86"
SLOT="0"

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

IUSE="doc source"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	unzip -qq "redist/${P}-src.zip"
	mkdir src
	mv com src
	rm redist/*
	# do not delete stuff after it's zipped
	sed -i -e "/<delete/d" build.xml
}

src_compile() {
	eant bin_release $(use_doc doc_release)
}
src_install() {
	java-pkg_newjar redist/${P}-bin.jar
	dodoc *.txt
	use doc && java-pkg_dojavadoc javadoc
	use source && java-pkg_dosrc src/com
}