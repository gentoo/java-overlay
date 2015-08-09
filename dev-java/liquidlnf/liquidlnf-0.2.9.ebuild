# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

inherit java-pkg-2 java-ant-2

DESCRIPTION="Provides a look and feel based on the Mosfet Liquid KDE 3.x theme"
HOMEPAGE="https://liquidlnf.dev.java.net/"
SRC_URI="https://liquidlnf.dev.java.net/files/documents/3605/40518/${P}-src.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="source doc"

CDEPEND="dev-java/laf-plugin"
DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		${CDEPEND}"
RDEPEND=">=virtual/jre-1.4
		${CDEPEND}"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PV}/patch-to-rm-bootclasspath.patch"
	rm lib/*.jar
	cd lib
	java-pkg_jarfrom laf-plugin
}

src_compile() {
	eant
}

src_install() {
	java-pkg_dojar dist/bin/liquidlnf.jar
	use source && java-pkg_dosrc src/*
	use doc && java-pkg_dohtml -r www/*
}
