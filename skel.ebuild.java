# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=1
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION=""
HOMEPAGE=""
MY_PV=
MY_PN=
MY_P=${MY_PN}-${PV}
SRC_URI="${P}.zip"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"

IUSE=""

COMMON_DEP="
	"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		${COMMON_DEP}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
}

EANT_BUILD_TARGET=""
EANT_DOC_TARGET=""

src_install() {
	java-pkg_dojar
	use doc && java-pkg_dojavadoc
	use source && java-pkg_dosrc
}
