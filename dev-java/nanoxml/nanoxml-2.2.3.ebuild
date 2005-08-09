# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg eutils

MY_PN="NanoXML"
MY_P="${MY_PN}-${PV}"
DESCRIPTION="A small XML parser for Java."
HOMEPAGE="http://nanoxml.cyberelf.be/"
SRC_URI="http://nanoxml.cyberelf.be/downloads/${MY_P}.tar.gz"

LICENSE="ZLIB"
SLOT="2.2"
KEYWORDS="~x86"
IUSE="doc"

DEPEND="virtual/jdk"
RDEPEND="virtual/jre
	dev-java/sax"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd ${S}

	# slightly patch build.sh
	# TODO maybe do an ant script?
	epatch ${FILESDIR}/${P}-gentoo.patch
}

src_compile() {
	sh build.sh
}

src_install() {
	java-pkg_dojar Output/*.jar
	use doc && java-pkg_dohtml -r Documentation/api
}
