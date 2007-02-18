# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN="jrefactory"
DESCRIPTION="ant code Beautifier from jrefactory package"
HOMEPAGE="http://jrefactory.sourceforge.net/"
SRC_URI="mirror://sourceforge/${MY_PN}/${MY_PN}-${PV}-source.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 "
IUSE="doc source examples"

DEPEND=">=virtual/jdk-1.5
		app-arch/unzip
		dev-java/ant-core
		=dev-java/findbugs-0.8*
		=dev-java/jaxen-1.1*
		dev-java/saxpath
		dev-java/sun-jai-bin
		source? ( app-arch/zip )
"
RDEPEND="${DEPEND} >=virtual/jre-1.5"
S="${WORKDIR}"

EANT_BUILD_TARGET="pretty"
EANT_DOC_TARGET="javadocs"
EANT_GENTOO_CLASSPATH="ant-core,saxpath,findbugs-0.8,sun-jai-bin,jaxen-1.1"

src_unpack(){
	unpack ${A}
	cd ${S} || die "cd failed"
	rm -f "${S}/JRefactoryModule.jar" \
		  "${S}/netbeans/modules/JRefactory.jar" \
		  "${S}/jar/dummy/jrefactory.jar"\
		  || die "rm failed"
	for i in $(find ${S}/build*xml);do
		java-ant_rewrite-classpath "$i"
	done
}

src_install() {
	echo "${ANT_TASK_PV}"
	cd "${S}"/ant.build/lib/ || die "cd failed"
	mv PrettyPrinter-${PV}.jar ${PN}.jar || die "mv failed"
	java-pkg_dojar ${PN}.jar
	java-pkg_register-ant-task
	cd "${S}" || die "cd return failed"
	use doc && java-pkg_dojavadoc docs/api
	use source && java-pkg_dosrc  "${S}/src"
}
