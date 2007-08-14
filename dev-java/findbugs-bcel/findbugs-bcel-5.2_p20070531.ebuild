# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/bcel/bcel-5.2.ebuild,v 1.6 2007/04/15 13:04:29 nixnut Exp $

# The tarball is created using patch from findbugs located at src/patches/bcel.diff
# and using corresponding svn revision from bcel sources

JAVA_PKG_IUSE="source"
inherit eutils java-pkg-2 java-ant-2

BCEL_PN="bcel"
BCEL_P="${BCEL_PN}-5.2"
DESCRIPTION="The Byte Code Engineering Library patched for performance for findbugs package"
HOMEPAGE="http://jakarta.apache.org/bcel/"
SRC_URI="mirror://apache/jakarta/${BCEL_PN}/source/${BCEL_P}-src.tar.gz
	http://dev.gentoo.org/~fordfrog/distfiles/findbugs-bcel-5.2_p20070531.patch.bz2"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
RDEPEND=">=virtual/jre-1.5
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.5
	app-arch/unzip
	${COMMON_DEP}"
S="${WORKDIR}/${BCEL_P}"

src_unpack() {
	unpack ${A}
	cd ${S}
	einfo "Applying findbugs patch..."
	echo "" > build.xml
	patch -p7 < ${WORKDIR}/${P}.patch
}

src_install() {
	java-pkg_newjar bcel.jar
	dodoc README.txt || die

	use source && java-pkg_dosrc src/java/*
}
