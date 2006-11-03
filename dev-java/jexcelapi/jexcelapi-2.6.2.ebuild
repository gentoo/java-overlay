# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jexcelapi/jexcelapi-2.5.1.ebuild,v 1.5 2005/07/16 10:00:34 axxo Exp $

inherit eutils java-ant-2 java-pkg-2

MY_P="${P//-/_}"
MY_P="${MY_P//./_}"

DESCRIPTION="A Java API to read, write, and modify Excel spreadsheets"
HOMEPAGE="http://jexcelapi.sourceforge.net/"
SRC_URI="mirror://sourceforge/jexcelapi/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="2.5"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.3
		dev-java/ant-core"
RDEPEND=">=virtual/jre-1.3"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}

	cd ${S}
	rm -rf jxl.jar docs
}

src_compile() {
	cd ${S}/build
	eant jxl $(use_doc docs)
}

src_install() {
	java-pkg_newjar jxl.jar  ${PN}.jar

	java-pkg_dohtml index.html tutorial.html
	use doc && java-pkg_dohtml -r docs/*
	use source && java-pkg_dosrc ${S}/src/*
}
