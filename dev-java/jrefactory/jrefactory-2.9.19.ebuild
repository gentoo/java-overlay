# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Open source Java refactoring tool"
HOMEPAGE="http://jrefactory.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-source.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 "
IUSE="doc source"

DEPEND=">=virtual/jdk-1.5
		app-arch/unzip
		dev-java/ant-core
		dev-java/ant-pretty
		=dev-java/findbugs-0.8*
		=dev-java/jaxen-1.1*
		dev-java/saxpath
		dev-java/sun-jai-bin
		source? ( app-arch/zip )
"
RDEPEND="${DEPEND} >=virtual/jre-1.5"
S="${WORKDIR}"

EANT_BUILD_TARGET="jar"
EANT_DOC_TARGET="javadocs"
EANT_GENTOO_CLASSPATH="ant-core,saxpath,findbugs-0.8,sun-jai-bin,jaxen-1.1"

src_unpack(){
	unpack ${A}
	cd ${S} || die "cd failed"
	epatch ${FILESDIR}/ant.patch
	epatch ${FILESDIR}/FindBugsFrame.java.diff
	rm -f "${S}/JRefactoryModule.jar" \
		  "${S}/netbeans/modules/JRefactory.jar" \
		  "${S}/jar/dummy/jrefactory.jar"\
		  || die "rm failed"
	for i in $(find ${S}/build*xml);do
		java-ant_rewrite-classpath "$i"
	done
}

src_install() {
	cd "${S}"/ant.build/lib/ || die "cd failed"
	rm -f PrettyPrinter-${PV}.jar || die "mv failed"
	java-pkg_dojar *.jar
	cd "${S}" || die "cd return failed"
	use doc && java-pkg_dojavadoc docs/api
	use source && java-pkg_dosrc  "${S}/src"
}
