# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Graph library that is a simpler and faster alternative to JGraph"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
HOMEPAGE="http://jgrapht.sourceforge.net"
KEYWORDS="~amd64"
SLOT="0"
LICENSE="LGPL-2.1"
IUSE="test"

CDEPEND="dev-java/touchgraph-graphlayout
	dev-java/jgraph"

DEPEND="${CDEPEND}
	>=virtual/jdk-1.5
	test? ( dev-java/ant-junit
		dev-java/xmlunit:1 )"

RDEPEND="${CDEPEND}
	>=virtual/jre-1.4"

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_GENTOO_CLASSPATH="touchgraph-graphlayout jgraph"
EANT_DOC_TARGET="javadoc"

src_unpack() {
	unpack ${A}
	rm -rf "${S}/lib" || die
}

src_install() {
	java-pkg_newjar ${PN}*.jar || die

	dohtml README.html || die
	use doc && java-pkg_dojavadoc javadoc
	use source && java-pkg_dosrc src/org
}

src_test() {
	EANT_GENTOO_CLASSPATH="${EANT_GENTOO_CLASSPATH} xmlunit:1" ANT_TASKS="ant-junit" eant test
}
