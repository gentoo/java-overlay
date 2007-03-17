# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="source"

inherit java-pkg-2

DESCRIPTION="Escher is a collection of libraries for X Window System written purely in Java."
HOMEPAGE="http://escher.sourceforge.net"
SRC_URI="${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

JAVA_PKG_WANT_SOURCE="1.4"

src_unpack() {
	unpack ${A}
	cd "${S}"
	mkdir -p build/classes build/javadoc
}

src_compile() {
	ejavac -d build/classes gnu/x11/*.java gnu/util/*.java \
	gnu/app/Application.java
	rm -R build/classes/gnu/x11/test
	jar cf "build/${PN}.jar" build/classes/* || die "Unable to create jar"
}

src_install() {
	java-pkg_dojar "build/${PN}.jar"
	#use doc && java-pkg_dojavadoc build/javadoc
	use source && java-pkg_dosrc gnu
}

