# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

JAVA_PKG_IUSE="doc source"
inherit base java-pkg-2 java-ant-2

MY_P="${PN}-${PV/_/}"

DESCRIPTION="Java source code formatter"
HOMEPAGE="http://jalopy.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}-src.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/antlr:0
	dev-java/log4j"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.4"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_GENTOO_CLASSPATH="antlr log4j"
S="${WORKDIR}/${MY_P}/${PN}"

java_prepare() {
	# Not sure why some source files need moving.
	cp -f src/antlrout/de/hunsicker/${PN}/language/antlr/* \
		src/java/de/hunsicker/${PN}/language/antlr/ || die
}

src_install() {
	local jar="${S}/H:/sh/newjalopy/merged/temp/${PN}/${MY_P}.jar"

	# The property files don't get included for some reason.
	cd src/java || die
	$(java-config -j) uf "${jar}" `find -name "*.properties"` || die
	cd ../.. || die

	java-pkg_newjar "${jar}"
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
