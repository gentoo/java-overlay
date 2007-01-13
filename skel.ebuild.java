# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION=""
HOMEPAGE=""
MY_PN=
MY_P=${MY_PN}-${PV}
SRC_URI="${P}.zip"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"

IUSE="doc source"

COMMON_DEP="
	"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		app-arch/unzip
		source? ( app-arch/zip )
		${COMMON_DEP}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
}

EANT_BUILD_TARGET="
EANT_DOC_TARGET="

src_install() {
	java-pkg_dojar
	use doc && java-pkg_dojavadoc
	use source && java-pkg_dosrc
}
