# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: nichoj
# Purpose:
#
inherit java-pkg

HOMEPAGE=""
MY_PV="${PV/_alpha/-alpha-}"
MY_P="${PN}-${MY_PV}"
S="${WORKDIR}/${MY_P}"
SRC_URI="http://gentooexperimental.org/distfiles/${MY_P}.tar.bz2 http://gentooexperimental.org/distfiles/build-wagon.xml.bz2"

DEPEND=">=virtual/jdk-1.4
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"


wagon_src_unpack() {
	unpack ${A}
	cd ${S}
	cp ${WORKDIR}/build-wagon.xml build.xml
}

wagon_src_compile() {
	local antflags="jar -Dproject.name=${PN}"
	use doc && antflags="${antflags} javadoc"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	ant ${antflags} || die "build failed!"
}

wagon_src_install() {
	java-pkg_dojar dist/${PN}.jar
	use doc && java-pkg_dohtml -r dist/doc/api
}

EXPORT_FUNCTIONS src_unpack src_compile src_install
