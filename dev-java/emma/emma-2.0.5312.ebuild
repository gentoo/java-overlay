# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="a free Java code coverage tool"
HOMEPAGE="http://emma.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.zip"

LICENSE="CPL-1.0"
SLOT="0"
KEYWORDS="~x86"

# No support for javadocs in build.xml
IUSE="source"

RDEPEND="=virtual/jre-1.4*"
DEPEND="=virtual/jdk-1.4*
		dev-java/ant-core
		app-arch/unzip
		source? ( app-arch/zip )"

EANT_BUILD_TARGET="build"

src_install() {
	java-pkg_dojar dist/${PN}.jar
	java-pkg_jarinto /usr/share/ant-core/lib/
	java-pkg_dojar dist/${PN}_ant.jar
	java-pkg_dolauncher ${PN} --main emmarun
	# One of these does not have java sources
	use source && java-pkg_dosrc */*/com 2> /dev/null
}
