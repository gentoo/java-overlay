# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/echo2/echo2-2.0.0.ebuild,v 1.3 2006/09/10 16:52:18 nelchael Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Echo2 Extras are additional components for the Echo Web Framework"
HOMEPAGE="http://www.nextapp.com/platform/echo2/extras/"
SRC_URI="NextApp_Echo2_Extras-${PV}.tgz"

DOWNLOAD_URI="http://www.nextapp.com/downloads/echo2extras/${PV}/NextApp_Echo2_Extras.tgz"

LICENSE="MPL-1.1 GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc ~x86"
IUSE="doc source"

COMMON_DEP="=dev-java/servletapi-2.4*
	>=dev-java/echo2-2.1.0_beta5"

DEPEND=">=virtual/jdk-1.4
	source? ( app-arch/zip )
	${COMMON_DEP}"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S=${WORKDIR}/NextApp_Echo2_Extras/

pkg_nofetch() {
	ewarn
	ewarn "NextApp uses broken file naming, all versions of Echo2"
	ewarn "are named NextApp_Echo2_Extras.tgz."
	ewarn
	ewarn "Please download following file:"
	ewarn " ${DOWNLOAD_URI}"
	ewarn "and move it to:"
	ewarn " ${DISTDIR}/${SRC_URI}"
	ewarn
}

src_unpack() {
	unpack ${A}

	cd ${S}/SourceCode

	echo "servlet.lib.jar=$(java-pkg_getjars servletapi-2.4)" >> ant.properties
	echo "echo2.app.lib.jar=$(java-pkg_getjar echo2-2.1 Echo2_App.jar)" >> ant.properties
	echo "echo2.webcontainer.lib.jar=$(java-pkg_getjar echo2-2.1 Echo2_WebContainer.jar)" >> ant.properties
	echo "echo2.webrender.lib.jar=$(java-pkg_getjar echo2-2.1 Echo2_WebRender.jar)" >> ant.properties
}

src_compile() {
	cd SourceCode

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
