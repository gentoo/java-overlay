# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Java Graph Editing Framework"
HOMEPAGE="http://gef.tigris.org"

MY_PN="GEF"
SRC_URI="http://${PN}.tigris.org/files/documents/9/23799/${MY_PN}-${PV}-src.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"

IUSE="source"

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core
		app-arch/unzip
		source? ( app-arch/zip )
		${RDEPEND}"

S=${WORKDIR}/src

src_unpack() {
	mkdir src
	cd src
	unpack ${A}
	rm "${S}"/*.jar
}
src_compile() {
	# The javadoc target does not work out of the box
	# feel free to submit a patch to bugs.gentoo.org
	eant package
}

src_install() {
	java-pkg_dojar ../lib/${PN}.jar
	use source && java-pkg_dosrc org
	dodoc README.txt
}

