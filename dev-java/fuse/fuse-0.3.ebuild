# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

JAVA_PKG_IUSE="doc source examples"

inherit java-pkg-2 java-ant-2

DESCRIPTION="Fuse is a lightweight resource injection library specifically
designed for GUI programming."
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

src_unpack() {
	unpack "${A}"

	cd "${S}"
	mkdir www
	epatch "${FILESDIR}/${P}-fix-build.xml.patch"

	echo "fuse.version=${PV}" > build.properties
	echo "swt.path=`java-pkg_getjars swt-3`" >> build.properties
	echo "ss_css2.path=`java-pkg_getjars cssparser`" >> build.properties

}

EANT_DOC_TARGET="doc"

src_install() {
	java-pkg_dojar "dist/${P}/lib/${PN}-core.jar"
	java-pkg_dojar "dist/${P}/lib/${PN}-swing.jar"
	java-pkg_dojar "dist/${P}/lib/${PN}-swt.jar"

	use doc && java-pkg_dojavadoc "dist/${P}/doc/api"
	use source && java-pkg_dosrc src

	if use examples; then
		dodir "/usr/share/doc/${PF}/examples"
		cp -r demo/* "${D}/usr/share/doc/${PF}/examples"
	fi
}
