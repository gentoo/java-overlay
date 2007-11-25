# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2
DESCRIPTION="An auxiliary findbugs.sourceforge.net plugin for bug detectors that fall outside the narrow scope of detectors to be packaged with the product itself."
HOMEPAGE="http://fb-contrib.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${PV}.zip"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE=""
CDEPEND=">=dev-java/asm-3
	dev-java/findbugs
	dev-java/findbugs-bcel"
DEPEND=">=virtual/jdk-1.5
	app-arch/unzip
	doc? ( dev-java/ant-trax )
	${CDEPEND}"
RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"
S="${WORKDIR}"

src_unpack() {
	unpack ${A}

	rm -fr "${S}"/classes "${S}"/javadoc "${S}"/htdocs
	find -name "*.jar" | xargs rm -v

	java-ant_rewrite-classpath
}

src_compile() {
	use doc && ANT_TASKS="ant-trax"
	eant jar $(use_doc javadoc html) \
		-Dgentoo.classpath=$(java-pkg_getjars asm-3,findbugs,findbugs-bcel)
}

src_install() {
	java-pkg_newjar ${P}.jar
	dosym /usr/share/${PN}/lib/fb-contrib.jar /usr/share/findbugs/plugin/

	if use doc ; then
		java-pkg_dojavadoc javadoc
		dohtml htdocs/*
	fi

	use source && java-pkg_dosrc src/com
}
