# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"
COMMIT="5a4fb65"
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="Java implementation of the JavaScript Object Notation"
HOMEPAGE="http://www.json.org/java/"
SRC_URI="https://github.com/douglascrockford/JSON-java/tarball/${COMMIT} -> ${P}.tar.gz"
LICENSE="json"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND=">=virtual/jdk-1.4
	test? ( dev-java/junit:4 )"

RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/douglascrockford-JSON-java-${COMMIT}"
JAVA_SRC_DIR="src"

java_prepare() {
	chmod a-x *.java || die
	mkdir -p src test || die
	cd src || die
	ln -snf ../*.java . || die
	rm -f Test.java || die
}

src_install() {
	java-pkg-simple_src_install
	dodoc README || die
}

src_test() {
	ejavac -cp "$(java-pkg_getjars junit-4):${PN}.jar" -d test Test.java
	ejunit4 -cp "${PN}.jar:test" org.json.Test
}
