# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Cewolf is a tag library for charts of all kinds. It enables every JSP to easily embedd chart images."
HOMEPAGE="http://cewolf.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-bin-src.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.4
	>=dev-java/ant-core-1.6
	app-arch/unzip
	source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4
	>=dev-java/jfreechart-1.0.0
	>=dev-java/jcommon-1.0.0
	>=dev-java/batik-1.6
	dev-java/commons-logging
	=dev-java/servletapi-2.4*
	>=dev-java/crimson-1.1.3
	>=dev-java/gnu-jaxp-1.0.0
	>=dev-java/log4j-1.2.12"


src_unpack() {
	unpack ${A}

	cp ${FILESDIR}/${P}-build.xml ${S}/build.xml

	cd ${S}/lib
	rm $(ls *.jar|grep -v demo)

	for module in awt-util dom svggen util xml; do
		java-pkg_jar-from batik-1.6 batik-${module}.jar
	done
	java-pkg_jar-from commons-logging
	java-pkg_jar-from crimson-1
	java-pkg_jar-from gnu-jaxp
	java-pkg_jar-from jcommon-1.0
	java-pkg_jar-from jfreechart-1.0
	# TODO jfreechart-demo
	#java-pkg_jar-from junit
	java-pkg_jar-from log4j
	java-pkg_jar-from servletapi-2.4
}

src_compile() {
	eant jar -Dnoget=true $(use_doc)
}

src_install() {
	java-pkg_dojar target/${PN}.jar
	dodoc LICENSE.txt RELEASE.txt

	use doc && java-pkg_dohtml -r javadoc docs/*
	use source && java-pkg_dosrc src/main/java/de
}
