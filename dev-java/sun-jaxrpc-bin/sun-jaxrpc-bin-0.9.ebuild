# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

MY_PN="jaxrpc"
MY_PV="${PV/./_}-pfd2"
MY_P=${MY_PN}-${MY_PV}
DESCRIPTION=""
HOMEPAGE=""
SRC_URI="${MY_P}-api-class.zip doc? (${MY_P}-apidocs.zip)"
RESTRICT="fetch"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

DEPEND="app-arch/unzip"
RDEPEND="virtual/jre"

src_unpack() {
	mkdir ${S}
	cd ${S}
	unpack ${A}
	use doc && mv javadocs api
}

src_install() {
	java-pkg_dojar ${MY_PN}-api.jar
	use doc && java-pkg_dohtml -r api
}
