# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/burlap/burlap-2.1.12-r1.ebuild,v 1.3 2007/01/16 17:31:45 betelgeuse Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="The Burlap web service protocol."
HOMEPAGE="http://www.caucho.com/burlap/"
SRC_URI="http://www.caucho.com/${PN}/download/${P}-src.jar"

LICENSE="Apache-1.1"
SLOT="2.1"
KEYWORDS="~amd64 ~x86"

IUSE="doc source"

COMMON_DEP="~dev-java/servletapi-2.3"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND="=virtual/jdk-1.4*
	app-arch/unzip
	dev-java/ant-core
	source? ( app-arch/zip )
	${COMMON_DEP}"

src_unpack() {
	mkdir -p ${P}/src
	cd ${P}/src || die
	unpack ${A}

	cd ${S}
	cp ${FILESDIR}/build-${PV}.xml build.xml || die
}

src_compile() {
	eant -Dproject.name=${PN} jar $(use_doc) \
		-Dclasspath=$(java-pkg_getjar servletapi-2.3 servlet.jar)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dojavadoc dist/doc/api
	use source && java-pkg_dosrc src/*
}
