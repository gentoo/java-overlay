# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

MY_PN="jalopy-ant"
MY_P="${MY_PN}-${PV}-1.5rc3"

JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2

DESCRIPTION="Apache Ant's optional tasks for Jalopy"
HOMEPAGE="http://jalopy.sourceforge.net/jalopy-ant/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}-src.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/antlr:0
	dev-java/log4j
	dev-java/ant-core
	dev-java/jalopy"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.4"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_GENTOO_CLASSPATH="antlr log4j ant-core jalopy"
S="${WORKDIR}/${MY_P}/${MY_PN}"

src_install() {
	local jar="${S}/H:/sh/newjalopy/merged/temp/${MY_PN}/${MY_P}.jar"

	# The property files don't get included for some reason.
	cd src/java || die
	$(java-config -j) uf "${jar}" `find -name "*.properties"` || die
	cd ../.. || die

	java-pkg_newjar "${jar}"
	java-pkg_register-ant-task
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src/java/*
}
