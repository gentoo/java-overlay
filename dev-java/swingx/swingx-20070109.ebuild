# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 versionator

MY_PV="2007_01_09"
DESCRIPTION="A collection of powerful, useful, and just plain fun Swing components."
HOMEPAGE="http://swinglabs.org/index.jsp"
SRC_URI="http://www.counties.co.nz/alistair/distfiles/${PN}-${MY_PV}-src.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

DEPEND=">=virtual/jdk-1.5
		app-arch/unzip
		dev-java/ant-core
		>=dev-java/junit-4
		>=dev-java/jmock-1.1.0
		dev-java/filters
		>=dev-java/batik-1.6
		dev-java/swing-worker"		
RDEPEND=">=virtual/jre-1.5
		>=dev-java/jmock-1.1.0"

S="${WORKDIR}/${PN}-${MY_PV}-src"

src_unpack(){
	unpack ${A}
	cd ${S}/lib
	
	rm -R *
	mkdir optional
	
	java-pkg_jar-from junit-4 junit.jar log4j-4.0.jar

	#jmock-1.1.0 seems to be slotted in 1.0
	java-pkg_jar-from jmock-1.0 jmock.jar jmock-1.1.0RC1.jar
	cd optional

	java-pkg_jar-from swing-worker
	
	java-pkg_jar-from batik-1.6 batik-awt-util.jar MultipleGradientPaint.jar

	java-pkg_jar-from filters filters.jar Filters.jar

}

src_compile(){
	eant jar $(use_doc javadoc)
}

src_install() {
	java-pkg_dojar dist/${PN}.jar
	$(use doc) & java-pkg_dojavadoc dist/javadoc/
}
