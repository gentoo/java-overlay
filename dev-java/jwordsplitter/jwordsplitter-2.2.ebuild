# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="source"

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="jWordSplitter a a small Java library that splits compound words into their parts."
HOMEPAGE="http://sourceforge.net/projects/jwordsplitter/"
SRC_URI="http://dev.gentoo.org/~serkan/distfiles/${P}.tar.bz2"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4"

EANT_BUILD_TARGET="build"

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	epatch "${FILESDIR}"/${P}.build.xml.patch
}

src_install() {
	java-pkg_dojar dist/jWordSplitter.jar
	use source && java-pkg_dosrc src/*
	dodoc README.txt || die
}
