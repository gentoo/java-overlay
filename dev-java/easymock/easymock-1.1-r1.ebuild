# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_P="${PN}${PV}"
DESCRIPTION="EasyMock provides Mock Objects for interfaces in JUnit tests by generating them on the fly using Java's proxy mechanism"
HOMEPAGE="http://www.easymock.org/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"

# TODO figure out license
LICENSE=""
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

COMMON_DEPEND="dev-java/junit"
DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	${COMMON_DEPEND}
	app-arch/zip"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"
S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd ${S}
	cp ${FILESDIR}/build-${PV}.xml build.xml || die "Failed to copy build.xml"

	unzip -qq -d src/ src.zip
}

src_compile() {
	eant jar $(use_doc) \
		-Dproject.name=${PN} \
		-Dclasspath=$(java-pkg_getjars junit)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dohtml -r dist/doc/api
}
