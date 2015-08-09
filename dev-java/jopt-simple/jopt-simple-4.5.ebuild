# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
JAVA_PKG_IUSE="doc source"

inherit vcs-snapshot java-pkg-2 java-pkg-simple

DESCRIPTION="A Java library for parsing command line options"
HOMEPAGE="http://pholser.github.com/jopt-simple/"
SRC_URI="https://github.com/pholser/${PN}/tarball/${P} -> ${P}.tar.gz"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="test" # Needs org.infinitest.toolkit.

RDEPEND=">=virtual/jre-1.5"

DEPEND=">=virtual/jdk-1.5
	test? ( dev-java/junit:4 )"

S="${WORKDIR}/${P}"
JAVA_SRC_DIR="src/main/java"

java_prepare() {
	# Easier to use java-pkg-simple.
	rm -v pom.xml || die
}

src_install() {
	java-pkg-simple_src_install
	dodoc README.md
}

src_test() {
	local CP="${DIR}:${PN}.jar:$(java-pkg_getjars junit-4)"
	local TESTS=$(find src/test/java -name "*Test.java")
	TESTS="${TESTS//src\/test\/java\/}"
	TESTS="${TESTS//.java}"
	TESTS="${TESTS//\//.}"

	mkdir -p target/test || die
	ejavac -cp "${CP}" -d target/test $(find src/test/java -name "*.java")
	ejunit4 -classpath "${CP}" ${TESTS}
}
