# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 versionator

MY_PV=$(replace_all_version_separators '_')

DESCRIPTION="ExplicitLayout is a powerful layout manager for Java"
HOMEPAGE="http://www.zookitec.com/explicitlayout.html"
SRC_URI="http://www.zookitec.com/explicit_${MY_PV}.zip"

LICENSE="LGPL-2.1"
SLOT="3.0"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		>=dev-java/ant-core-1.5*"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	cd ${S}
	rm -r lib/* docs/*	
}

src_compile() {
	eant dist $(use_doc doc)
}

src_install() {
	java-pkg_dojar lib/explicit.jar
	use doc && java-pkg_dohtml -r docs/api
	use source && java-pkg_dosrc src
}
