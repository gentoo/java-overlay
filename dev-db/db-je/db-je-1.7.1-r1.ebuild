# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit base java-pkg-2 java-ant-2

MY_PN=${PN##db-}
MY_P=${MY_PN}-${PV}
DESCRIPTION="Berkeley DB JE is a high performance, transactional storage engine written entirely in Java"
HOMEPAGE="http://sleepycat.com/products/je.shtml"
SRC_URI="http://downloads.sleepycat.com/${MY_P}.tar.gz"

LICENSE="Sleepycat"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

DEPEND="=virtual/jdk-1.4*
	dev-java/ant-core"
RDEPEND="=virtual/jre-1.4*"
S="${WORKDIR}/${MY_P}"

# allows you to disable testing
PATCHES="${FILESDIR}/${P}-build.patch"

src_compile() {
	eant jar $(use_doc -Ddoc.dir=./docs/api javadoc-all) -Dnotest=true
}

src_install() {
	java-pkg_dojar build/lib/je.jar
	dodoc README

	use doc && java-pkg_dohtml -r docs/api
}
