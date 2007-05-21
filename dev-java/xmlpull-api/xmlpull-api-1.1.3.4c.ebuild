# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc examples source test"

inherit eutils java-pkg-2 java-ant-2

MY_PN=${PN//-api/}
MY_V=_${PV//./_}
MY_P=${MY_PN}${MY_V}
DESCRIPTION="The aim of that library is to provide a similar but orthogonal pull parsing basis to widely successful push parsing SAX API."
HOMEPAGE="http://xmlpull.org/index.shtml"

SRC_URI="http://${MY_PN}.org/v1/download/${MY_P}_src.tgz"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86"

IUSE="test-framework"

DEP="test-framework? ( dev-java/junit dev-java/xpp3 )"

RDEPEND=">=virtual/jre-1.5 ${DEP}"
DEPEND=">=virtual/jdk-1.5 ${DEP} test? ( dev-java/ant-junit )"

EANT_BUILD_TARGET="api samples"
EANT_EXTRA_ARGS="$(use test-framework && echo "tests")"
EANT_DOC_TARGET="apidoc"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	rm ${MY_P}.jar || die
	epatch "${FILESDIR}/build.xml.diff"
	if use test-framework;then
		mkdir -p "${S}/build/lib" || die
		d "${S}/build/lib" || die
		java-pkg_jarfrom junit
		java-pkg_jarfrom xpp3
	fi
}

src_test() {
	ANT_TASKS="ant-junit" eant junit
}

src_install() {
	cd "${S}"/build/lib
	java-pkg_newjar "${MY_P}.jar" "$(basename "${MY_P}.jar" ${MY_V}.jar).jar"
	use test-framework && \
	java-pkg_newjar "${MY_PN}-tests${MY_V}.jar" "$(basename "${MY_PN}-tests${MY_V}.jar" ${MY_V}.jar).jar"
	use source && java-pkg_dosrc "${S}/src/java"
	use doc && java-pkg_dojavadoc "${S}/doc/api"
	use examples && java-pkg_doexamples "${S}/build/samples"
}



