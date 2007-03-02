# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_ANT_TASKS="ant-junit"

inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="A toolkit for managing graphs and graph based data structures"
HOMEPAGE="http://jakarta.apache.org/commons/"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"
SLOT="0"
RDEPEND=">=virtual/jdk-1.4
	dev-java/jdepend
	dev-java/log4j
	dev-java/commons-collections
	dev-java/xml-commons"
DEPEND="${RDEPEND}
	source? ( app-arch/zip )"
LICENSE="Apache-2.0"
KEYWORDS=""
IUSE="doc"
EANT_BUILD_TARGET="jar  -Dnoget=true"
EANT_DOC_TARGET="javadoc"
EANT_GENTOO_CLASSPATH="log4j,commons-collections,xml-commons,jdepend,junit"

src_unpack (){
	unpack ${A}
	for build in $(find "${S}" -name build*xml);do
		# get rid of tests classpath
		sed -i $build -re\
			's:pathelement path="\$\{testclassesdir\}":pathelement path="\$\{gentoo.classpath\}\:\$\{testclassesdir\}":g'
		java-ant_rewrite-classpath "$build"
	done
}

src_install(){
	java-pkg_newjar target/${PN}-*.jar ${PN}.jar
	use doc && java-pkg_dojavadoc dist/docs/api
	use source && java-pkg_dosrc src
}
