# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jcommon/jcommon-0.9.7-r1.ebuild,v 1.6 2005/10/08 11:03:05 betelgeuse Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A collection of useful classes used by JFreeChart, JFreeReport and other projects."
HOMEPAGE="http://www.jfree.org"
SRC_URI="mirror://sourceforge/jfreechart/${P}.tar.gz"
LICENSE="LGPL-2"
SLOT="0.8"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc"
DEPEND=">=virtual/jdk-1.3
		dev-java/ant-core
		dev-java/junit"
RDEPEND=">=virtual/jdk-1.3"

src_unpack() {
	unpack ${A}
	cd ${S}
	rm *.jar
}

src_compile() {
	eant -f ant/build.xml compile $(use_doc)
}

src_install() {
	java-pkg_newjar ${P}.jar ${PN}.jar
	dodoc README.txt
	use doc && java-pkg_dohtml -r javadoc
}

