# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION=""
HOMEPAGE="http://cewolf.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"

LICENSE="GPL-2.1"
SLOT="0.10"
KEYWORDS="~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core
	app-arch/unzip
	source? (app-arch/zip)"
RDEPEND=">=virtual/jre-1.4
	=dev-java/jfreechart-0.9*
	=dev-java/jcommon-0.9*
	=dev-java/batik-1.5.1*
	dev-java/commons-logging
	=dev-java/servletapi-2.4*"


src_unpack() {
	unpack ${A}

	cd ${S}/lib
	rm $(ls *.jar|grep -v demo) 

	for module in awt-util dom svggen util xml; do
		java-pkg_jar-from batik-1.5.1 batik-${module}.jar
	done
	java-pkg_jar-from commons-logging
	java-pkg_jar-from jcommon
	java-pkg_jar-from jfreechart jfreechart.jar jfreechart-0.9.21.jar
	# TODO jfreechart-demo
	java-pkg_jar-from servletapi-2.4
}

src_compile() {
	local antflags="jar"
	use doc && antflags="${antflags} javadoc -Ddir.apidoc=build/api"
	ant ${antflags} || die "ant failed"
}

src_install() {
	java-pkg_dojar build/${PN}.jar
	dodoc release.txt
	
	use doc && java-pkg_dohtml -r build/api docs/*
	use source && java-pkg_dosrc src/*
}
