# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"

JAVA_PKG_IUSE="source"

inherit java-pkg-2

DESCRIPTION="A small Java library with one purpose: To instantiate a new object of a class."
HOMEPAGE="http://objenesis.googlecode.com/"
SRC_URI="http://objenesis.googlecode.com/files/objenesis-1.1-sources.jar"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE=""

COMMON_DEP=""

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${COMMON_DEP}"

src_compile() {
	mkdir -p build || die
	cp -R META-INF build || die
	ejavac -d build $(find org -iname '*.java')

	jar -cf "${PN}.jar" build/*
}
	
src_install() {
	java-pkg_dojar "${PN}.jar"
	use source && java-pkg_dosrc org
}

