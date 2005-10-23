# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

DESCRIPTION="Free JSSE implementation"
HOMEPAGE="http://www.nongnu.org/jessie"
SRC_URI="http://syzygy.metastatic.org/jessie/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc ssl"
#IUSE="doc jikes ssl"

RDEPEND=">=virtual/jre-1.4
	ssl? ( dev-java/gnu-crypto )"

DEPEND=">=virtual/jdk-1.4
	${RDEPEND}"

# Jikes needs to learn how to get system libraries so it can play nice.
# Until then, we're going to disable jikes support
#	jikes? ( >=dev-java/jikes-1.19 )

src_unpack() {
	unpack ${A}
	cd ${S}
	# TODO file upstream
	# without this, make apidoc fails (a URL has changed)
	epatch ${FILESDIR}/${P}-javadoc.patch
}

src_compile() {

	local MY_CLASSPATH=${CLASSPATH}
	use ssl && MY_CLASSPATH=${MY_CLASSPATH}:$(java-pkg_getjars gnu-crypto)

#	local MY_JAVAC=$(java-config -c)
#	if use jikes; then
#		MY_JAVAC=$(which jikes)
#		MY_CLASSPATH=${MY_CLASSPATH}:$(java-config -O)/jre/lib/rt.jar
#	fi

	# Must check later that this actually works
	CLASSPATH=${MY_CLASSPATH} econf --with-java-target=1.4 --disable-awt || die
	make || die
	use doc && emake apidoc
}

src_install() {
	einstall || die
	rm ${D}/usr/share/*.jar

	java-pkg_dojar lib/*.jar
	if use doc; then
		mv apidoc api
		java-pkg_dohtml -r api
	fi
	dodoc AUTHORS FAQ INSTALL NEWS README THANKS TODO
}
