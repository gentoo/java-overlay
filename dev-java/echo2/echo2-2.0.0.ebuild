# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="Echo2 is the next-generation of the Echo Web Framework"
HOMEPAGE="http://www.nextapp.com/platform/echo2/echo/"
SRC_URI="http://www.nextapp.com/downloads/echo2/${PV}/NextApp_Echo2.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

DEPEND="virtual/jdk"
RDEPEND="virtual/jre
	>=dev-java/servletapi-2.4"

S="${WORKDIR}/NextApp_Echo2/"

src_compile() {

	export CLASSPATH=`java-config -p servletapi-2.4`
	cd "${S}/SourceCode"
	ant dist || die "ant failed"

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
