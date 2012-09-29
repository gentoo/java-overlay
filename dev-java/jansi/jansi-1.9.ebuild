# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
MY_P="jansi-project-${PV}"
JAVA_PKG_IUSE="doc source"

inherit vcs-snapshot java-pkg-2 java-pkg-simple

DESCRIPTION="Jansi is a small Java library that allows you to use ANSI escape sequences in your console output"
HOMEPAGE="http://jansi.fusesource.org/"
SRC_URI="https://github.com/fusesource/${PN}/tarball/${MY_P} -> ${MY_P}.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND=">=virtual/jre-1.5
	dev-java/hawtjni-runtime:0
	dev-java/jansi-native:0"

DEPEND=">=virtual/jdk-1.5
	dev-java/hawtjni-runtime:0
	dev-java/jansi-native:0
	test? ( dev-java/junit:4 )"

S="${WORKDIR}/${MY_P}/${PN}"
JAVA_SRC_DIR="src/main/java"
JAVA_GENTOO_CLASSPATH="hawtjni-runtime,jansi-native"

java_prepare() {
	# Easier to use java-pkg-simple.
	rm -v pom.xml || die
}

src_install() {
	java-pkg-simple_src_install
	dodoc ../{changelog,readme}.md
}

src_test() {
	cd src/test/java || die

	local CP=".:${S}/${PN}.jar:$(java-pkg_getjars junit-4,${JAVA_GENTOO_CLASSPATH})"
	local TESTS=$(find * -name "*Test.java")
	TESTS="${TESTS//.java}"
	TESTS="${TESTS//\//.}"

	ejavac -cp "${CP}" -d . $(find * -name "*.java")
	ejunit4 -classpath "${CP}" ${TESTS}
}
