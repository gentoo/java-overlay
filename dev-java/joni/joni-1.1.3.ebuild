# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"
JAVA_PKG_IUSE="source"
inherit base java-pkg-2 java-ant-2

DESCRIPTION="Java port of the Oniguruma regular expression engine"
HOMEPAGE="http://jruby.codehaus.org/"
SRC_URI="http://dev.gentooexperimental.org/~chewi/distfiles/${P}.tbz2"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/asm:3
	dev-java/jcodings"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.5"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_BUILD_TARGET="build"
EANT_GENTOO_CLASSPATH="asm-3 jcodings"

src_install() {
	java-pkg_dojar target/${PN}.jar
	use source && java-pkg_dosrc src/*
}
