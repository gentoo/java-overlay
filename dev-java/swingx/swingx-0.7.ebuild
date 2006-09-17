# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 versionator

MY_PV=$(replace_all_version_separators _)
DESCRIPTION="A collection of powerful, useful, and just plain fun Swing components."
HOMEPAGE="http://swinglabs.org/index.jsp"
SRC_URI="https://jdnc.dev.java.net/files/documents/1746/11864/jdnc-${MY_PV}-src.zip"

LICENSE="LGPL-2.1"
SLOT="0.7"
KEYWORDS="-* ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.5
		app-arch/unzip
		>=dev-java/ant-core-1.5
		dev-java/jnlp-bin
		dev-java/junit
		dev-java/jlfgr"		
RDEPEND=">=virtual/jre-1.5
		dev-java/jlfgr"

S=${WORKDIR}/jdnc-${MY_PV}


src_unpack(){
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/fix-jdnc-build.xml.patch
	mkdir dist dist/lib dist/test
	cd swingx/lib
	rm jlfgr-1_0.jar
	java-pkg_jarfrom jlfgr
}

src_compile(){
	cd swingx/make
	eant build
}

src_install() {
	java-pkg_dojar ${S}/dist/bin/${PN}.jar
}
