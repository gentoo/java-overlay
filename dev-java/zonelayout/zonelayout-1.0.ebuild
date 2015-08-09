# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Simple, intuitive, powerful, source-code-based system
			for designing Graphical User Interfaces"
HOMEPAGE="http://www.zonelayout.com/index.php"
SRC_URI="http://zonelayout.googlecode.com/files/${P}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm *.jar
	mkdir "classes"
}

src_compile() {
	ejavac -d classes `find src/ -type f -name \*.java -print0 | xargs --null`
	jar cf zonelayout.jar -C classes/ .
}

src_install() {
	java-pkg_dojar "${PN}.jar"
	use doc && java-pkg_dojavadoc javadoc
	use source && java-pkg_dosrc src/*
}
