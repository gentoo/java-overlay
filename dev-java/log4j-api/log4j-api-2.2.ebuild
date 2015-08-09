# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple

MY_P="apache-log4j-${PV}-src"
DESCRIPTION="API for Java's Apache Log4j"
HOMEPAGE="http://logging.apache.org/log4j/"
SRC_URI="mirror://apache/logging/log4j/${PV}/${MY_P}.tar.gz"
LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="~amd64"
IUSE="test"

# Chewi keeps getting class cast exceptions but can't figure out
# why. Even swapping in the upstream jars doesn't work.
RESTRICT="test"

CDEPEND="dev-java/osgi-core-api:0"

RDEPEND=">=virtual/jre-1.6
	${CDEPEND}"

DEPEND=">=virtual/jdk-1.6
	${CDEPEND}
	test? (
		dev-java/commons-lang:3.3
		dev-java/hamcrest-core:1.3
		dev-java/log4j-core:2
		dev-java/junit:4
	)"

S="${WORKDIR}/${MY_P}/${PN}/src"
JAVA_SRC_DIR="main/java"
JAVA_GENTOO_CLASSPATH="osgi-core-api"

java_prepare() {
	# Cowardly avoiding some test dependencies.
	rm -r test/java/org/apache/logging/log4j/osgi || die
}

src_test() {
	cd test/java || die

	local CP=".:../resources:${S}/${PN}.jar:$(java-pkg_getjars commons-lang-3.3,hamcrest-core-1.3,log4j-core-2,junit-4,${JAVA_GENTOO_CLASSPATH})"
	local TESTS=$(find * -name "*Test.java")
	TESTS="${TESTS//.java}"
	TESTS="${TESTS//\//.}"

	ejavac -cp "${CP}" -d . $(find * -name "*.java")
	ejunit4 -classpath "${CP}" ${TESTS}
}
