# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc examples source"

inherit eutils java-pkg-2 java-ant-2

MY_PN=${PN//-api/}
MY_V=_${PV//./_}
MY_P=${MY_PN}${MY_V}
DESCRIPTION="XmlPull V1 API"
HOMEPAGE="http://xmlpull.org"

SRC_URI="http://${MY_PN}.org/v1/download/${MY_P}_src.tgz"
LICENSE="as-is test-framework? ( LGPL-2.1 )"
SLOT="0"
KEYWORDS="~x86"

IUSE="test-framework"

COMMON_DEP="test-framework? ( dev-java/junit )"

RDEPEND=">=virtual/jre-1.5 ${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.5 ${COMMON_DEP}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	rm ${MY_P}.jar || die
	epatch "${FILESDIR}/build.xml.diff"
	if use test-framework;then
		mkdir -p "${S}/build/lib" || die
		java-pkg_jarfrom --into "${S}/build/lib" junit
	fi
}

src_compile() {
	eant jar $(use_doc apidoc) \
		$(use test-framework && echo tests) \
		-Dbuild_apidoc=api
}

# Could be done by depending on xpp3 for example but the test are meant
# for testing the implementation so makes little sense
#src_test() {
#	ANT_TASKS="ant-junit" eant junit
#}

src_install() {
	cd "${S}"/build/lib || die
	java-pkg_newjar ${MY_P}.jar
	use test-framework && \
		java-pkg_newjar ${MY_PN}-tests${MY_V}.jar ${MY_PN}-tests.jar
	cd "${S}"
	dohtml README.html || die
	dohtml -r doc || die
	dodoc doc/*.txt || die
	use source && java-pkg_dosrc "${S}/src/java"
	if use doc; then
		java-pkg_dojavadoc "${S}/api"
		cd "${D}/usr/share/doc/${PF}/html"
		ln -s ../api doc/api || die
	fi
	use examples && java-pkg_doexamples "${S}/src/java/samples"
}
