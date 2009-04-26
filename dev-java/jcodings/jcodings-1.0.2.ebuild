# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
JAVA_PKG_IUSE="source"
inherit base java-pkg-2 java-ant-2

DESCRIPTION="Byte-based encoding support library for Java"
HOMEPAGE="http://jruby.codehaus.org/"
SRC_URI="http://svn.jruby.codehaus.org/browse/~tarball=tbz2/jruby/${PN}/tags/${PV}/${PV}.tbz2 -> ${P}.tbz2"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.5"

EANT_BUILD_TARGET="build"
S="${WORKDIR}"

src_install() {
	java-pkg_dojar target/${PN}.jar
	use source && java-pkg_dosrc src/*
}
