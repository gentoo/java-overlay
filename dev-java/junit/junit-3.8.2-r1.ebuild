# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/junit/junit-3.8.2.ebuild,v 1.1 2006/11/15 03:46:13 wltjr Exp $

inherit java-pkg-2 java-ant-2

MY_P=${P/-/}
S=${WORKDIR}/${MY_P}
DESCRIPTION="Simple framework to write repeatable tests"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"
HOMEPAGE="http://www.junit.org/"
LICENSE="CPL-1.0"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE="doc source"
DEPEND=">=virtual/jdk-1.3
	source? ( app-arch/zip )
	>=dev-java/ant-core-1.4
	>=app-arch/unzip-5.50-r1"
RDEPEND=">=virtual/jre-1.3"

src_unpack() {
	unpack ${A}
	cd ${S}
	unzip src.jar || die
	rm -f junit.jar
	cp ${FILESDIR}/${P}-build.xml ${S}/build.xml
}

src_compile() {
	eant dist
}

src_install() {
	use source && java-pkg_dosrc junit
	cd ${MY_P}
	java-pkg_dojar junit.jar
	java-pkg_dohtml -r README.html cpl-v10.html
	use doc && java-pkg_dohtml -r doc javadoc
}
