# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1
JAVA_PKG_IUSE="doc source test"
inherit java-pkg-2 java-ant-2

RESTRICT="test"
DESCRIPTION="Java library for reading and writing CSV and plain delimited text files"
HOMEPAGE="http://www.csvreader.com/java_csv.php"
SRC_URI="mirror://sourceforge/${PN}/${P/-/}.zip"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
DEPEND=">=virtual/jdk-1.5
	test? ( dev-java/junit:4 )"
RDEPEND=">=virtual/jre-1.5"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	rm -rfv doc "${PN}".jar || die "error cleaning up"
	mv -v src/AllTests.java . || die "error moving tests"
}

src_compile() {
	eant dist
	use doc && eant -f javadoc.xml
}

src_install() {
	java-pkg_dojar ${PN}.jar
	use doc && java-pkg_dojavadoc doc
	use source && java-pkg_dosrc src/*
}

src_test() {
	#Tests don't work atm.
	ejavac -cp ${PN}.jar:$(java-pkg_getjars --build-only junit-4) AllTests.java
	#java -cp .:${PN}.jar:$(java-pkg_getjars --build-only junit-4) -Djava.awt.headless=true junit.textui.TestRunner AllTests || die "Running junit failed"
	#ejunit -cp .:${PN}.jar AllTests
}
