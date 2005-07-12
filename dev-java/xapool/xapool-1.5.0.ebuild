# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

MY_P="${P}-src"
DESCRIPTION="XAPool is an open source XA Pool !"
HOMEPAGE="http://xapool.experlog.com/"
SRC_URI="http://download.fr2.forge.objectweb.org/${PN}/${MY_P}.tgz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc jikes"

DEPEND="virtual/jdk
	dev-java/ant
	jikes? (dev-java/jikes)"
RDEPEND="virtual/jre
	=dev-java/carol-2*
	dev-java/commons-logging
	dev-java/sun-j2ee-connector-bin
	dev-java/howl-logger
	dev-java/jta
	dev-java/log4j
	dev-java/p6spy"
S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd ${S}
	
	epatch ${FILESDIR}/${P}-gentoo.patch
	# don't build oracle or instantdb support
	epatch ${FILESDIR}/${P}-no-instandb-no-oracle.patch

	cd externals
	rm *.jar
	java-pkg_jar-from carol-2 ow_carol.jar
	java-pkg_jar-from commons-logging commons-loggin.jar
	java-pkg_jar-from sun-j2ee-connector-bin
	java-pkg_jar-from howl-logger howl.jar
	java-pkg_jar-from jta
	java-pkg_jar-from log4j
	java-pkg_jar-from p6spy
}

src_compile() {
	local antflags="jar"
	use jikes && antflags="-Dbuild.compiler=jikes ${antflags}"
	use doc && antflags="${antflags} jdoc -Ddist.jdoc=output/dist/api"

	ant ${antflags} || die "Compilation failed"
}

src_install() {
	java-pkg_dojar output/dist/lib/*.jar
	dodoc README.txt
	use doc && java-pkg_dohtml -r output/dist/api
}
