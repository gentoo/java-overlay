# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="2"
JAVA_PKG_IUSE="doc source"

inherit eutils java-pkg-2 java-ant-2

MY_P="${PN}_${PV}"

DESCRIPTION="Docking solution for Java Swing"
HOMEPAGE="http://www.vlsolutions.com/en/products/docking/"
SRC_URI="http://www.vlsolutions.com/download/cecill/${MY_P}.zip"

LICENSE="CeCILL-1"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"

S="${WORKDIR}/${MY_P}"

java_prepare() {
	rm jar/${MY_P}.jar || die "rm fialed"
	epatch "${FILESDIR}"/${P}-buildfix.patch
}

src_install() {
	java-pkg_newjar jar/${MY_P}.jar ${PN}.jar
	use doc && java-pkg_dojavadoc doc/api
	use source && java-pkg_dosrc src/com
}
