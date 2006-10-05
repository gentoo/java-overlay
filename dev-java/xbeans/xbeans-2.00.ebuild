# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Software component that takes XML as input and processes it in some fashion"
HOMEPAGE="http://www.xbeans.org"
SRC_URI="mirror://sourceforge/xbeans/Xbeans-r${PV}.zip"

LICENSE=""
SLOT="2"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/xalan
		dev-java/xerces
		dev-java/xml-commons"
		#xsltc here
DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		dev-java/ant-core
		${CDEPEND}"
RDEPEND=">=virtual/jre-1.4
		${CDEPEND}"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/xbeans-compile-fix.patch
	cp ${FILESDIR}/build.xml .

	cd lib
	rm *.jar
	java-pkg_jarfrom xml-commons xml-apis.jar
	java-pkg_jarfrom xalan xalan.jar
	java-pkg_jarfrom xerces-1.3
	#xsltc.jar needs to be added here
}

src_compile() {
	eant dist javadoc
}

src_install() {
	java-pkg_dojar dist/*.jar
	java-pkg_dojavadoc api
}
