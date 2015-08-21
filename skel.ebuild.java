# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
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

CDEPEND="
	"

RDEPEND=">=virtual/jre-1.6
	${CDEPEND}"
DEPEND=">=virtual/jdk-1.6
		app-arch/unzip
		${CDEPEND}"

S=${WORKDIR}/${MY_P}

EANT_BUILD_TARGET=""
EANT_DOC_TARGET=""

java_prepare() {

}

src_install() {
	java-pkg_dojar package.jar
	use doc && java-pkg_dojavadoc path/to/docs
	use source && java-pkg_dosrc path/to/src
}
