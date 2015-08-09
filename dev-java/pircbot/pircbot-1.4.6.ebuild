# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="doc source"
inherit java-pkg-2

DESCRIPTION="PircBot is a Java framework for writing IRC bots quickly and easily."
HOMEPAGE="http://www.jibble.org/pircbot.php"
SRC_URI="http://www.jibble.org/files/${P}.zip"

LICENSE="|| ( GPL-2 jibble.org )"
KEYWORDS="~amd64"
IUSE=""
SLOT="0"

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	unzip -q pircbot.jar -d src || die
	find . -name '*.class' -delete
}

src_compile() {
	cd src
	find . -name '*.java' -print > sources.list
	ejavac @sources.list
	find . -name '*.class' -print > classes.list
	touch myManifest
	jar cmf myManifest ${PN}.jar @classes.list
}

src_install() {
	java-pkg_dojar src/${PN}.jar
	use source && java-pkg_dosrc src/org
	use doc && java-pkg_dojavadoc javadocs
}
