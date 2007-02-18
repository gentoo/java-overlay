# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Find Bugs in Java Programs"
HOMEPAGE="http://findbugs.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-source.zip"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86 "
IUSE="doc source examples"

DEPEND=">=virtual/jdk-1.5
		app-arch/unzip
		dev-java/bcel
		dev-java/ant-nodeps
		dev-java/ant-tasks
		dev-java/ant-core
		dev-java/jaxen
		dev-java/apple-java-extensions-bin
		=dev-java/dom4j-1.4
		dev-java/saxpath
		=dev-java/junit-3.8*
		=dev-java/asm-3*
"
RDEPEND="${DEPEND} >=virtual/jre-1.5"

WANT_ANT_TASKS="ant-nodeps"
EANT_DOC_TARGET="apiJavadoc"
EANT_BUILD_TARGET="jars build"
EANT_GENTOO_CLASSPATH="ant-tasks,ant-core"

src_unpack(){
	unpack ${A}
	pushd "${S}/lib"
	# FIXME: use old bcel, either we use embedded or
	#        we make an old ebuild to re-born
	# java-pkg_jarfrom bcel
	java-pkg_jarfrom apple-java-extensions-bin,junit
	java-pkg_jarfrom asm-3 asm.jar           asm-3.0.jar
	java-pkg_jarfrom asm-3 asm-analysis.jar asm-analysis-3.0.jar
	java-pkg_jarfrom asm-3 asm-commons.jar   asm-commons-3.0.jar
	java-pkg_jarfrom asm-3 asm-tree.jar     asm-tree-3.0.jar
	java-pkg_jarfrom asm-3 asm-util.jar     asm-util-3.0.jar
	java-pkg_jarfrom asm-3 asm-xml.jar      asm-xml-3.0.jar
	java-pkg_jarfrom dom4j-1.4 dom4j-full.jar dom4j-full.jar
	popd
	for i in $(find "${S}" -name build*xml);do
		java-ant_rewrite-classpath "$i"
	done
}

src_install() {
	java-pkg_dojar ${S}/lib/${PN}*.jar ${S}/plugin/*.jar
	use doc && java-pkg_dojavadoc "${S}/apiJavaDoc"
	use source && java-pkg_dosrc "${S}/src"
}
