# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc test source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Commons-Math is a library of lightweight, self-contained mathematics and statistics components addressing the most common practical problems not immediately available in the Java programming language."
HOMEPAGE="http://jakarta.apache.org/commons/math/"
SRC_URI="mirror://apache/jakarta/commons/math/source/${P}-src.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""

COMMON_DEP="
	>=dev-java/commons-discovery-0.2
	>=dev-java/commons-logging-1.0.3"

DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.6
	${COMMON_DEP}
	test? ( dev-java/ant-junit )"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S=${WORKDIR}/${P}-src

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/commons-math-1.1.build.xml.patch"

	mkdir lib
	cd lib
	java-pkg_jar-from commons-discovery
	java-pkg_jar-from commons-logging
}

src_test() {
	cd lib || die
	java-pkg_jar-from junit
	cd ..
	ANT_TASKS="ant-junit" eant test
}

src_install() {
	java-pkg_dojar target/${PN}.jar

	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/org
}
