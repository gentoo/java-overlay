# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="source"
inherit java-pkg-2

DESCRIPTION="An implementation of the UUIDs and GUIDs specification in Java"
HOMEPAGE="http://johannburkard.de/software/uuid/"
SRC_URI="http://johannburkard.de/software/uuid/uuid-${PV}-sources.jar"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.5"
RDEPEND=">=virtual/jre-1.5"

src_compile() {
	rm -rf bin || die
	mkdir -p bin || die

	ejavac -d bin -encoding UTF-8 `find com -name "*.java" || die`
	`java-config -j` cvf "${PN}.jar" -C bin . || die
}

src_install() {
	java-pkg_dojar "${PN}.jar"
	use source && java-pkg_dosrc com
}
