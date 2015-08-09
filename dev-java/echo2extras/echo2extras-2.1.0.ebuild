# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=2

JAVA_PKG_IUSE="doc source"
inherit java-pkg-2 java-ant-2

DESCRIPTION="Echo2 Extras are additional components for the Echo Web Framework"
HOMEPAGE="http://echo.nextapp.com/site/echo2/addons/extras"
SRC_URI="http://www.nextapp.com/downloads/echo2extras/${PV}/NextApp_Echo2_Extras.tgz -> NextApp_Echo2_Extras-${PV}.tgz"

LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
SLOT="2.1"
KEYWORDS="~amd64"
IUSE=""

COMMON_DEP="java-virtuals/servlet-api:2.4
	>=dev-java/echo2-2.1.0_rc4"

DEPEND=">=virtual/jdk-1.4
	${COMMON_DEP}"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S=${WORKDIR}/NextApp_Echo2_Extras/

src_prepare() {
	rm -rfv BinaryLibraries || die
	cd SourceCode || die
	echo "servlet.lib.jar=$(java-pkg_getjars servlet-api-2.4)" >> ant.properties
	echo "echo2.app.lib.jar=$(java-pkg_getjar echo2-2.1 Echo2_App.jar)" >> ant.properties
	echo "echo2.webcontainer.lib.jar=$(java-pkg_getjar echo2-2.1 Echo2_WebContainer.jar)" >> ant.properties
	echo "echo2.webrender.lib.jar=$(java-pkg_getjar echo2-2.1 Echo2_WebRender.jar)" >> ant.properties
	java-pkg-2_src_prepare
}

src_compile() {
	cd SourceCode || die
	eant dist $(use_doc doc.public)
}

src_install() {
	java-pkg_dojar SourceCode/dist/lib/*.jar
	use doc && {
		cp Documentation/api/public/*.html SourceCode/javadoc/public
		java-pkg_dojavadoc SourceCode/javadoc/public
	}
	use source && java-pkg_dosrc SourceCode/src
	dodoc readme.txt
}
