# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=1
JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2 eutils

DESCRIPTION="A rich collection of web components which seamlessly integrate with the Echo Web Framework"
HOMEPAGE="http://echopoint.sourceforge.net/"
SRC_URI="mirror://sourceforge/echopoint/${PN}-src-${PV/_/}.zip"

LICENSE="MPL-1.1 GPL-2 LGPL-2.1"
SLOT="2.1"
KEYWORDS="~amd64"
IUSE="doc source"

COMMON_DEP="java-virtuals/servlet-api:2.4
	>=dev-java/echo2-2.1.0_beta5"

DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S="${WORKDIR}/echopointng"

src_unpack() {
	unpack ${A}
	cd "${S}" || die
	
	epatch "${FILESDIR}"/${P}-disabletestcompile.patch
	sed -i -e "s/toUpperCase()/toUpperCase(java.util.Locale.ENGLISH)/g" $(find . -name "*.java") || die "fixing toUpperCase usage failed"
	sed -i -e "s/toLoweCase()/toLowerCase(java.util.Locale.ENGLISH)/g" $(find . -name "*.java") || die "fixing toLowerCase usage failed"

	echo "javax_servlet_jar=$(java-pkg_getjar servlet-api-2.4 servlet-api.jar)" >> build.properties
	echo "javax_jsp_jar=$(java-pkg_getjar servlet-api-2.4 jsp-api.jar)" >> build.properties
	echo "echo_app_jar=$(java-pkg_getjar echo2-2.1 Echo2_App.jar)" >> build.properties
	echo "echo_webcontainer_jar=$(java-pkg_getjar echo2-2.1 Echo2_WebContainer.jar)" >> build.properties
	echo "echo_webrender_jar=$(java-pkg_getjar echo2-2.1 Echo2_WebRender.jar)" >> build.properties
}

src_compile() {
	eant compileJar $(use_doc)

	use source && eant releaseSrc
}

src_install() {
	java-pkg_newjar dist_build/binary/jar/${PN}-${PV/_/}.jar

	use doc && java-pkg_dojavadoc dist_javadoc/docs/

	use source && {
		cd "${S}"/dist_jar
		unzip *.zip
		java-pkg_dosrc echopointng
		cd ..
	}
}
