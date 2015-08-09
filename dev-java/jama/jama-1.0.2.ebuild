# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

MY_PN="Jama"
MY_P="${MY_PN}-${PV}"

JAVA_PKG_IUSE="doc source"
inherit base java-pkg-2

DESCRIPTION="A Java matrix package"
HOMEPAGE="http://math.nist.gov/javanumerics/jama/"
SRC_URI="http://math.nist.gov/javanumerics/jama/${MY_P}.tar.gz"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.2"
RDEPEND=">=virtual/jre-1.2"

S="${WORKDIR}"

src_compile() {
	mkdir -p build || die
	ejavac -d build $(find Jama -name '*.java')
	$(java-config -j) cf "${MY_PN}.jar" -C build Jama || die
}

src_install() {
	java-pkg_dojar "${MY_PN}.jar"
	dodoc Jama/ChangeLog || die
	use doc && java-pkg_dojavadoc Jama/doc
	use source && java-pkg_dosrc Jama
}
