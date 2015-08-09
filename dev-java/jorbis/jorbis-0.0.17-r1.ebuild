# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="JOrbis accepts Ogg Vorbis bitstreams and decodes them to raw PCM"
HOMEPAGE="http://www.jcraft.com/jorbis/"
SRC_URI="http://www.jcraft.com/${PN}/${P}.zip"
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.4"
DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"

S="${WORKDIR}/${P}"

src_install() {
	java-pkg-simple_src_install
	dodoc ChangeLog README
}
