# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source"
inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Java port of the Oniguruma regular expression engine"
HOMEPAGE="http://jruby.codehaus.org/"
SRC_URI="http://dev.gentooexperimental.org/~chewi/distfiles/${P}.tar.bz2"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.5"

EANT_BUILD_TARGET="build"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/exposure.patch"
}

src_install() {
	java-pkg_dojar target/${PN}.jar
	use source && java-pkg_dosrc src/*
}
