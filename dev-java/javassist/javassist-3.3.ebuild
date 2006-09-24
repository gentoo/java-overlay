# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit java-pkg-2 java-ant-2

# TODO add notes about where the distfile comes from
DESCRIPTION="Javassist makes Java bytecode manipulation simple."
SRC_URI="mirror://sourceforge/jboss/${P}.zip"
HOMEPAGE="http://www.csg.is.titech.ac.jp/~chiba/javassist/"

LICENSE="MPL-1.1"
SLOT="3.3"
KEYWORDS="~x86 ~amd64 ~ppc"
IUSE="doc source"

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		>=dev-java/ant-core-1.5
		source? ( app-arch/zip )"

src_unpack() {
	unpack ${A}
	cd ${S}
	java-ant_rewrite-classpath build.xml
}
src_compile() {
	eant clean jar $(use_doc javadocs) -Dgentoo.classpath=$(java-config --tools)
}

src_install() {
	java-pkg_dojar ${PN}.jar
	java-pkg_dohtml Readme.html
	use doc && java-pkg_dojavadoc html
	use source && java-pkg_dosrc src/main/javassist
}
