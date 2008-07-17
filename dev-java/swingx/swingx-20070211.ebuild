# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1
WANT_ANT_TASKS="ant-nodeps"
JAVA_PKG_IUSE="doc source examples"

inherit java-pkg-2 java-ant-2

MY_PV="2007_02_11"
MY_P="${PN}-${MY_PV}"
DESCRIPTION="A collection of powerful, useful, and just plain fun Swing components."
HOMEPAGE="http://swinglabs.org/index.jsp"
SRC_URI="https://swingx.dev.java.net/files/documents/2981/50412/${MY_P}-src.zip"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.5
		dev-java/swing-worker:0
		dev-java/batik:1.6"
DEPEND=">=virtual/jdk-1.5
		app-arch/unzip
		${RDEPEND}"

S="${WORKDIR}/${MY_P}-src"

src_unpack(){
	unpack "${A}"
	java-ant_rewrite-classpath "${S}/nbproject/build-impl.xml"
	cd "${S}/lib"
	rm -v *.jar */*.jar || die
}

EANT_GENTOO_CLASSPATH="batik-1.6,swing-worker"

src_install() {
	java-pkg_dojar "dist/${PN}.jar"
	use doc && java-pkg_dojavadoc dist/javadoc/

	use source && java-pkg_dosrc src/java/* src/beaninfo/*

	use examples && java-pkg_doexamples src/demo
}

