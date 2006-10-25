# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Commons-Math is a library of lightweight, self-contained mathematics and statistics components addressing the most common practical problems not immediately available in the Java programming language."
HOMEPAGE="http://jakarta.apache.org/commons/math/"
SRC_URI="mirror://apache/jakarta/commons/math/source/${P}-src.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~sparc ~ppc ~amd64 ~ppc64"
IUSE="doc test source"

DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-1.6
	test? ( >=dev-java/junit-3.7 )
	source? ( app-arch/zip )"

RDEPEND=">=virtual/jre-1.4
	>=dev-java/commons-discovery-0.2
	>=dev-java/commons-logging-1.0.3"

S=${WORKDIR}/${P}-src

src_unpack() {
	unpack ${A}

	cd ${S}

	epatch ${FILESDIR}/commons-math-1.1.build.xml.patch

	mkdir lib
	cd lib
	java-pkg_jar-from commons-discovery || die "Could not link to discovery"
	java-pkg_jar-from commons-logging || die "Could not link to commons-logging"
}

src_compile() {
	eant jar $(use_doc)
}

src_test() {
	! use test && die "To run the tests, you need to enable the \"test\" use flag"

	eant test
}

src_install() {
	java-pkg_dojar target/${PN}.jar

	use doc && java-pkg_dohtml -r dist/docs/
	use source && java-pkg_dosrc src/java/org
}
