# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

DESCRIPTION="Echo2 is the next-generation of the Echo Web Framework"
HOMEPAGE="http://www.nextapp.com/platform/echo2/echo/"
SRC_URI="NextApp_Echo2-${PV}.tgz"

DOWNLOAD_URI="http://www.nextapp.com/downloads/echo2/${PV}/NextApp_Echo2.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

RESTRICT="fetch"

DEPEND=">=virtual/jdk-1.4"
RDEPEND=">=virtual/jre-1.4
	>=dev-java/servletapi-2.4"

S="${WORKDIR}/NextApp_Echo2/"

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

src_compile() {

	export SERVLET_LIB_JAR=$(java-config -p servletapi-2.4)
	cd "${S}/SourceCode"
	eant dist || die "ant failed"

}

src_install() {

	java-pkg_dojar ${S}/SourceCode/dist/lib/*.jar

	use doc && {

		cd "${S}/Documentation"
		java-pkg_dohtml -r api

	}

	java-pkg_dohtml "${S}/Documentation/index.html"
	java-pkg_dohtml -r "${S}/Documentation/images"

	dodoc "${S}/readme.txt"

}
