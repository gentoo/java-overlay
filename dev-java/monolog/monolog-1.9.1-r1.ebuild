# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN="Monolog"
MY_P="${MY_PN}_${PV}_src"
DESCRIPTION="The goal of Monolog is to define and maintain the ObjectWeb API for the logging."
HOMEPAGE="http://monolog.objectweb.org/"
SRC_URI="http://download.forge.objectweb.org/${PN}/${MY_P}.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="
	dev-java/log4j
	dev-java/p6spy
	=dev-java/velocity-1*
	dev-java/ant-core
	dev-java/junit"
	
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"
src_unpack() {
	mkdir -p ${S}
	cd ${S}
	unpack ${A}


	cd externals
	rm *.jar
	java-pkg_jar-from ant-core,log4j,junit,p6spy,velocity
}

# TODO report problem with JRE detection, as in, only detects 1.4 correctly
src_compile() {
	eant -DcompatibleJRE=true clean jar
}

src_install() {
	java-pkg_dojar output/dist/lib/*.jar
}
