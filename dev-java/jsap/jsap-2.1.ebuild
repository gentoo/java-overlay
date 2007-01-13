# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Java Simple Arguments Parser (JSAP)"
HOMEPAGE="http://sourceforge.net/projects/jsap"
MY_PN=JSAP
MY_P=${MY_PN}-${PV}
SRC_URI="mirror://sourceforge/${PN}/${MY_P}-src.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"

COMMON_DEP="
	>=dev-java/ant-core-1.5.4
	dev-java/junit
	dev-java/xstream"

DEPEND="
	>=virtual/jdk-1.4
	${COMMON_DEP}
	=dev-java/snip-0.11*
	=dev-java/rundoc-0.11*"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/2.1-test-target.patch"
	java-ant_rewrite-classpath
	cd "${S}/lib"

	rm -v *.jar
}

EANT_GENTOO_CLASSPATH="junit,ant-core,xstream"

src_test() {
	eant test
}

src_install() {
	java-pkg_newjar dist/${MY_P}.jar ${PN}.jar

	if use doc; then
		dohtml doc/*.html
		java-pkg_dojavadoc doc/javadoc
		dosym /usr/share/doc/${PF}/html/api /usr/share/doc/${PF}/html/javadoc
	fi

	use source && java-pkg_dosrc src/java/com
}

