# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/excalibur-logger/excalibur-logger-2.1.ebuild,v 1.2 2006/12/22 18:12:09 betelgeuse Exp $

inherit base java-pkg-2 java-ant-2

DESCRIPTION="Pool from the Excalibur containerkit"
HOMEPAGE="http://excalibur.apache.org/component-list.html"
SRC_URI="mirror://apache/excalibur/${PN/-api}/source/${P}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"

IUSE="doc source"

RDEPEND=">=virtual/jre-1.4"

DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		source? ( app-arch/zip )"

S=${WORKDIR}/${PN}

PATCHES="${FILESDIR}/2.1-build.xml-javadoc.patch"

# has test target but there are no junit tests (maven generated?)

src_install() {
	java-pkg_newjar target/${P}.jar
	dodoc NOTICE.txt
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
