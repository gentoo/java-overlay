# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Echo2 is the next-generation of the Echo Web Framework"
HOMEPAGE="http://www.nextapp.com/platform/echo2/echo/"
SRC_URI="NextApp_Echo2-${PV}.tgz"

DOWNLOAD_URI="http://www.nextapp.com/downloads/echo2/${PV/_beta/.beta}/NextApp_Echo2.tgz"

LICENSE="MPL-1.1 GPL-2 LGPL-2.1"
SLOT="2.1"
KEYWORDS="~ppc ~x86"
IUSE="doc source"

RESTRICT="fetch"

COMMON_DEP="=dev-java/servletapi-2.4*"

DEPEND=">=virtual/jdk-1.4
	source? ( app-arch/zip )
	${COMMON_DEP}"

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEP}"

S=${WORKDIR}/NextApp_Echo2/

pkg_nofetch() {
	ewarn
	ewarn "NextApp uses broken file naming, all versions of Echo2"
	ewarn "are named NextApp_Echo2.tgz."
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
