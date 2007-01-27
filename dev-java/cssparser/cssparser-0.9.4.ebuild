# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="The CSS Parser inputs Cascading Style Sheets Level 2 source text and outputs a Document Object Model Level 2 Style tree."
HOMEPAGE="http://cssparser.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="source doc"

DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		source? ( app-arch/zip )"
RDEPEND=">=virtual/jre-1.4"

S="${WORKDIR}/${PN}"

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/${PN}.javadoc.patch
	rm *.jar
}

#This says that it needs javacc,  where?
EANT_BUILD_TARGET="dist"

src_install() {
	java-pkg_newjar ss_css2.jar
	use source && java-pkg_dosrc src
	use doc && java-pkg_dojavadoc javadoc
}
