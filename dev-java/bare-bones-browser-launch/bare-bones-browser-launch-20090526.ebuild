# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

MY_PN="BareBonesBrowserLaunch"

JAVA_PKG_IUSE="doc source"
inherit base java-pkg-2

DESCRIPTION="Simple browser launcher for Swing applications"
HOMEPAGE="http://www.centerkey.com/java/browser/"
SRC_URI="http://www.centerkey.com/java/browser/myapp/real/${MY_PN}.jar"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

S="${WORKDIR}"

src_compile() {
	mkdir -p build || die
	ejavac -d build $(find com -name '*.java')
	$(java-config -j) cf "${MY_PN}.jar" -C build com || die
}

src_install() {
	java-pkg_dojar "${MY_PN}.jar"
	use doc && java-pkg_dojavadoc doc
	use source && java-pkg_dosrc com
}
