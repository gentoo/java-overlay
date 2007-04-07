# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

MY_P=${P/-/_}
S=${WORKDIR}/${MY_P}

DESCRIPTION="ID3 Class Library Implementation"
HOMEPAGE="http://jid3.blinkenlights.org/"
SRC_URI="http://jid3.blinkenlights.org/release/${MY_P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86"
IUSE="source"

RDEPEND=">=virtual/jre-1.4"

DEPEND=">=virtual/jdk-1.4
	source? (app-arch/zip)"

src_unpack() {
	unpack ${A}
	cd ${S} && rm -rf src/org/blinkenlights/jid3/test
	#Dirty hack to get rid of tests
}

src_install() {
	java-pkg_dojar dist/JID3.jar
	use source && java-pkg_dosrc src/
}
