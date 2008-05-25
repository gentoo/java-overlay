# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc examples source"

inherit eutils java-pkg-2 java-ant-2

MY_PN=${PN//-api/}
MY_PV=_${PV//./_}
MY_P=${MY_PN}${MY_PV}
DESCRIPTION="XmlPull V1 API"
HOMEPAGE="http://xmlpull.org"

SRC_URI="http://${MY_PN}.org/v1/download/${MY_P}_src.tgz"
LICENSE="as-is test-framework? ( LGPL-2.1 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="addons test-framework"

COMMON_DEP="
	test-framework? ( dev-java/junit )
	addons? ( dev-java/junit )
	"

RDEPEND=">=virtual/jre-1.4 ${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEP}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	rm -v ${MY_P}.jar || die
	java-ant_ignore-system-classes
}

src_compile() {
	local antflags bo
	if use test-framework || use addons; then
		antflags="-Djunit_present=true \
			-Djava.class.path=$(java-pkg_getjars junit)"
	fi
	eant jar $(use_doc apidoc) \
		$(use test-framework && echo tests) \
		$(use addons && echo addons) \
		-Dbuild_apidoc=api ${antflags}
}

# Could be done by depending on xpp3 for example but the test are meant
# for testing the implementation so makes little sense
#src_test() {
#	ANT_TASKS="ant-junit" eant junit
#}

src_install() {
	cd "${S}"/build/lib || die
	for jar in *.jar; do
		java-pkg_newjar ${jar} ${jar//${MY_PV}}
	done
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
