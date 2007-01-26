# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION=""
HOMEPAGE="https://fuse.dev.java.net"
SRC_URI="${HOMEPAGE}/files/documents/4589/32550/${PN}-src-${PV}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND=">=virtual/jre-1.5
		dev-java/cssparser
		=dev-java/swt-3*"
DEPEND=">=virtual/jdk-1.5
		app-arch/unzip
		${RDEPEND}"

#S="${WORKDIR}/"

src_unpack() {
	unpack ${A}

	cd ${S}

	epatch ${FILESDIR}/${P}-fix-build.xml.patch

	echo "fuse.version=${PV}" > build.properties
	echo "swt.path=`java-pkg_getjars swt-3`" >> build.properties
	echo "ss_css2.path=`java-pkg_getjars cssparser`" >> build.properties

}

src_compile() {
	eant jar
}

src_install() {
	java-pkg_dojar dist/${P}/lib/*.jar
}
