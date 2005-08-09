# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

DESCRIPTION="http://tonicsystems.com/products/jarjar/"
HOMEPAGE="http://tonicsystems.com/products/jarjar/"
SRC_URI="mirror://sourceforge/${PN}/${PN}-src-${PV}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"

LIB_DEPEND="=dev-java/asm-2*
	=dev-java/gnu-regexp-1*"
DEPEND="virtual/jdk
	app-arch/unzip
	dev-java/ant
	jikes? (dev-java/jikes)
	${LIB_DEPEND}"
RDEPEND="virtual/jre
	${LIB_DEPEND}"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-properties.patch

	cd ${S}/lib
	rm *.jar
	java-pkg_jar-from gnu-regexp-1
	java-pkg_jar-from asm-2 asm.jar
}

src_compile() {
	local antflags="jar"
	use jikes && antflags="${antflags} -Dbuild.compiler=jikes"
	use doc && antflags="${antflags} javadoc -Djavadoc.dist.dir=dist/api"

	ant ${antflags} || die "Ant failed"
}

src_install() {
	java-pkg_newjar dist/${P}.jar ${PN}.jar
	use doc && java-pkg_dohtml -r dist/api
}
