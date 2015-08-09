# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="The JDesktop Integration Components (JDIC) API"
HOMEPAGE="https://jdic.dev.java.net/"
SRC_URI="https://jdic.dev.java.net/files/documents/880/16466/${P}-src.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="doc examples source"

DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		app-arch/unzip
		source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/${P}-src/"

src_unpack() {
	unpack ${A}
	cd "${S}"

	find -type d -name CVS -exec rm -r {} \; >/dev/null 2>&1

	# Originally made for dev-java/jdictrayapi (subset of this)
	epatch "${FILESDIR}/0.8.7-gentoo.patch"

	cd "${S}/${PN}"
	# https://jdic.dev.java.net/issues/show_bug.cgi?id=298
	epatch "${FILESDIR}/0.9.1-moz-pkgconfig.patch"

}

src_compile() {
	MOZILLA_PKG_CONFIG="gecko-sdk-gtkmozembed" eant buildall
}

src_install() {
	cd "${S}/dist/linux"
	java-pkg_dojar jdic.jar
	java-pkg_doso libtray.so
	use doc && java-pkg_dohtml -r "${S}"/../docs/*
	use source && java-pkg_dosrc "${S}"/src/share/classes/* "${S}"/src/unix/classes/*
	if use examples; then
		dodir "/usr/share/doc/${PF}/examples"
		cp -r "${S}"/demo/Tray/* "${D}/usr/share/doc/${PF}/examples/"
	fi
}
