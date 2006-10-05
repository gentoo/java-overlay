# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Fully customizable Java/Swing calendar component"
HOMEPAGE="http://${PN}.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${PV}.tar.bz2"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

src_unpack() {
	unpack ${A}
	cd "${S}"

	rm -rf doc/* lib/*
}

src_compile() {
	eant jar $(use_doc)
}

src_install() {
	java-pkg_newjar "lib/${P}.jar"
	dodoc *.txt
	use doc && java-pkg_dojavadoc doc
	use source && java-pkg_dosrc src/java/net
}
