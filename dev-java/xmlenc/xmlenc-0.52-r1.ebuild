# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /cvsroot/xins/xins-ebuild/xins-1.3.0.ebuild,v 1.1 2005/12/16 13:03:19 znerd Exp $

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="Performance-optimized XML output library for Java"
HOMEPAGE="http://xmlenc.sourceforge.net/"
SRC_URI="mirror://sourceforge/xmlenc/${P}.tgz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"

RDEPEND=">=virtual/jre-1.3"
DEPEND=">=virtual/jdk-1.3
	>=dev-java/ant-core-1.6
	source? ( app-arch/zip )"

src_unpack() {
	unpack "${A}"
	rm -rf "${S}/build" || die "Failed to remove ${S}/build"
}

src_compile() {
	eant jar $(use_doc javadoc-public)
}

src_install() {
	java-pkg_dojar build/*.jar
	use doc && java-pkg_dojavadoc build/javadoc
	use source && java-pkg_dosrc src/main/*
}
