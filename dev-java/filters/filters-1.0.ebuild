# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Java Image Processing Classes"
HOMEPAGE="http://www.jhlabs.com/ip/filters/"
SRC_URI="http://www.jhlabs.com/ip/${PN}/Filters.zip"

LICENSE="Apache-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.4
		app-arch/unzip
		dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4"


S=${WORKDIR}

src_compile() {
	eant jar
}

src_install() {
	java-pkg_newjar ./dist/Filters.jar
}
