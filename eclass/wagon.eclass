# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

#
# Original Author: nichoj
# Purpose: 
#
inherit java-pkg

ECLASS="wagon"
INHERITED="$INHERITED $ECLASS"

HOMEPAGE=""
MY_PV="${PV/_alpha/-alpha-}"
MY_P="${PN}-${MY_PV}"
S="${WORKDIR}/${MY_P}"
SRC_URI="mirror://gentoo/${MY_P}.tar.bz2 mirror://gentoo/build-wagon.xml.bz2"

DEPEND="virtual/jdk
	dev-java/ant-core"
RDEPEND="virtual/jre"


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
