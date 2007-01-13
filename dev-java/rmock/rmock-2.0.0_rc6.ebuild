# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PV=${PV/_rc/-rc-}
MY_P="${PN}-${MY_PV}"
DESCRIPTION=""
HOMEPAGE=""
SRC_URI="mirror://sourceforge/${PN}/${MY_P}-all.zip"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc source"

COMMON_DEPEND="=dev-java/junit-3* =dev-java/cglib-2.1*"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPEND}
	dev-java/ant-core
	app-arch/unzip
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPEND}"

S=${WORKDIR}/${MY_P}/${MY_P}

src_unpack() {
	unpack ${A}
	cd ${MY_P}
	unzip -qq ${MY_P}-src.zip

	cd ${S}
	mkdir -p target/lib && cd target/lib
	java-pkg_jar-from junit
	java-pkg_jar-from cglib-2.1 cglib.jar
}

src_compile() {
	eant -Dnotest=true -Dnoget=true jar $(use_doc)
}

src_install() {
	java-pkg_newjar target/${MY_P}.jar
	use doc && java-pkg_dojavadoc dist/docs/api
}
