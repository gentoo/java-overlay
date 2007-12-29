# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc"

inherit java-pkg-2 java-ant-2

MY_P="${PN}${PV}"
DESCRIPTION="EasyMock provides Mock Objects for interfaces in JUnit tests by generating them on the fly using Java's proxy mechanism"
HOMEPAGE="http://www.easymock.org/"
SRC_URI="mirror://sourceforge/easymock/${MY_P}.zip"

LICENSE="MIT"
SLOT="1"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="~dev-java/easymock-1.2
				=dev-java/cglib-2.0*"
DEPEND=">=virtual/jdk-1.5
	dev-java/ant-core
	${COMMON_DEPEND}
	app-arch/unzip"
RDEPEND=">=virtual/jre-1.5
	${COMMON_DEPEND}"
S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	cp "${FILESDIR}/build.xml" build.xml || die "Failed to copy build.xml"

	unzip -qq -d src/ src.zip
}

src_compile() {
	eant jar $(use_doc) \
		-Dproject.name="${PN}" \
		-Dclasspath=$(java-pkg_getjars easymock-1,cglib-2)
}

src_install() {
	java-pkg_dojar "dist/${PN}.jar"

	use doc && java-pkg_dojavadoc dist/doc/api
}
