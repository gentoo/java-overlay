# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xerces/xerces-2.8.1.ebuild,v 1.5 2007/02/12 04:57:27 nichoj Exp $

JAVA_PKG_IUSE="doc source"
WANT_ANT_TASKS="ant-nodeps"
inherit java-pkg-2 java-ant-2

MY_PN="JempBox"
MY_PV="${PV/_pre/-dev}"
MY_P="${MY_PN}-${MY_PV}"
DESCRIPTION="Java library that implements Adobe's XMP specification"
HOMEPAGE="http://www.jempbox.org"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.zip"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	
	rm lib/*.jar
	rm -rf docs/javadoc
}

EANT_BUILD_TARGET="package"

src_install() {
	java-pkg_newjar lib/${MY_P}.jar

	if use doc; then
		dohtml -r docs/*
		java-pkg_dojavadoc website/build/site/javadoc
	fi

	use source && java-pkg_dosrc src/org
}
