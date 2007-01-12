# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="an Apache ANT optional task that extracts snippets of code from text files"
HOMEPAGE="http://www.martiansoftware.com/lab/index.html"
SRC_URI="http://www.martiansoftware.com/lab/${PN}/${P}-src.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc source"

COMMON_DEP=">=dev-java/ant-core-1.5.4"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"
DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}"

src_unpack() {
	unpack ${A}

	cd "${S}"
	rm -v *.jar
	epatch "${FILESDIR}/${P}-build.xml.patch"
	java-ant_rewrite-classpath
	eant clean

}

EANT_GENTOO_CLASSPATH="ant-core"

src_install() {
	java-pkg_newjar dist/${P}.jar ${PN}.jar
	dodir /usr/share/ant-core/lib
	dosym /usr/share/${PN}/lib/${PN}.jar /usr/share/ant-core/lib/${PN}.jar

	use doc && java-pkg_dojavadoc javadoc
	use source && java-pkg_dosrc src/java/com
}

