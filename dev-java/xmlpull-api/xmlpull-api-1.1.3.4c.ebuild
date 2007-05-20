# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc examples source"

inherit eutils java-pkg-2 java-ant-2

MY_PN=${PN//-api/}
MY_P=${MY_PN}_${PV//./_}
MY_V=_${PV//./_}${R}
DESCRIPTION="The aim of that library is to provide a similar but orthogonal pull parsing basis to widely successful push parsing SAX API."
HOMEPAGE="http://xmlpull.org/index.shtml"

SRC_URI="http://${MY_PN}.org/v1/download/${MY_P}_src.tgz"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86"

IUSE=""

DEP="dev-java/junit"

RDEPEND=">=virtual/jre-1.5 ${DEP}"
DEPEND=">=virtual/jdk-1.5 ${DEP}"

EANT_BUILD_TARGET="all"
EANT_DOC_TARGET="apidoc"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	rm ${MY_P}.jar || die
	epatch "${FILESDIR}/build.xml.diff"
	cd "${S}/lib/junit" || die
	java-pkg_jarfrom junit
}

src_install() {
	for jar in $(find "${S}"/build/lib/*${MY_V}.jar);do
		local newjar="$(basename ${jar} ${MY_V}.jar).jar"
		java-pkg_newjar ${jar} ${newjar}
	done
	use source && java-pkg_dosrc "${S}/src/java"
	use doc && java-pkg_dojavadoc "${S}/doc/api"
	use examples && java-pkg_doexamples "${S}/build/samples"
}

