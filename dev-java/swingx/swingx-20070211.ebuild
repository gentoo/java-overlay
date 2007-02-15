# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $


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
KEYWORDS="~amd64"
IUSE=""


RDEPEND=">=virtual/jre-1.5
		>=dev-java/jmock-1.1.0
		dev-java/swing-worker
		>=dev-java/batik-1.6
		dev-java/ant-core"
DEPEND=">=virtual/jdk-1.5
		app-arch/unzip
		dev-java/emma
		${REDPEND}"

S="${WORKDIR}/${MY_P}-src"

src_unpack(){
	unpack "${A}"
	cd "${S}/lib"

	rm junit*

	#jmock-1.1.0 seems to be slotted in 1.0
	java-pkg_jar-from jmock-1.0 jmock.jar jmock-1.1.0RC1.jar
	cd optional

	java-pkg_jar-from swing-worker

	java-pkg_jar-from batik-1.6 batik-awt-util.jar MultipleGradientPaint.jar

	java-pkg_jar-from filters filters.jar Filters.jar

	cd ../build-only
	java-pkg_jarfrom emma



}

src_install() {
	java-pkg_dojar "dist/${PN}.jar"
	use doc && java-pkg_dojavadoc dist/javadoc/

	use source && java-pkg_dosrc src

	if use examples; then
		dodir "/usr/share/doc/${PF}/examples"
		cp -r src/demo/* "${D}/usr/share/doc/${PF}/examples"
	fi
}

