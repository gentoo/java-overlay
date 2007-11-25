# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_ANT_TASKS="ant-nodeps"
JAVA_PKG_IUSE="doc source test"
inherit java-pkg-2 java-ant-2

DESCRIPTION="Find Bugs in Java Programs"
HOMEPAGE="http://findbugs.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-source.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="dev-java/ant-core
	dev-java/apple-java-extensions-bin
	>=dev-java/asm-3.1
	=dev-java/dom4j-1.4
	dev-java/findbugs-bcel
	dev-java/jsr305
	test? (
		dev-java/ant-junit
		=dev-java/junit-3.8*
	)"
RDEPEND=">=virtual/jre-1.5
	${CDEPEND}"
DEPEND="=virtual/jdk-1.5*
	app-arch/unzip
	${CDEPEND}"

EANT_DOC_TARGET="apiJavadoc"
EANT_BUILD_TARGET="jars anttask"
EANT_GENTOO_CLASSPATH="ant-core"
ANT_OPTS="-Xmx256m"

pkg_setup() {
	use doc && ewarn "Installing javadocs does not pass sanity check."

	java-pkg-2_pkg_setup
}

src_unpack(){
	unpack ${A}

	cd "${S}"
	find -name "*.jar" | xargs rm -v
	cd "${S}"/lib
	java-pkg_jarfrom findbugs-bcel findbugs-bcel.jar bcel.jar
	java-pkg_jarfrom apple-java-extensions-bin,junit
	java-pkg_jarfrom asm-3 asm.jar asm-3.0.jar
	java-pkg_jarfrom asm-3 asm-analysis.jar asm-analysis-3.0.jar
	java-pkg_jarfrom asm-3 asm-commons.jar asm-commons-3.0.jar
	java-pkg_jarfrom asm-3 asm-tree.jar asm-tree-3.0.jar
	java-pkg_jarfrom asm-3 asm-util.jar asm-util-3.0.jar
	java-pkg_jarfrom asm-3 asm-xml.jar asm-xml-3.0.jar
	java-pkg_jarfrom dom4j-1.4 dom4j-full.jar dom4j-full.jar
	java-pkg_jarfrom jsr305
	use test && java-pkg_jarfrom junit

	cd "${S}"
	java-ant_rewrite-classpath
}

src_test() {
	ANT_TASKS="ant-nodeps ant-junit" eant runjunit
}

src_install() {
	java-pkg_dojar "${S}"/lib/${PN}*.jar "${S}"/plugin/*.jar
	dodir /usr/share/${PN}/plugin
	dosym /usr/share/${PN}/lib/coreplugin.jar  /usr/share/${PN}/plugin/
	dobin "${FILESDIR}"/findbugs

	use doc && java-pkg_dojavadoc "${S}"/apiJavaDoc
	use source && java-pkg_dosrc "${S}"/src
}
