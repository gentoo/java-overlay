# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jarbundler/jarbundler-1.4.ebuild,v 1.1 2005/12/13 08:36:43 compnerd Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Jar Bundler Ant Task"
HOMEPAGE="http://www.loomcom.com/jarbundler/"
SRC_URI="http://www.loomcom.com/${PN}/dist/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc"

DEPEND=">=virtual/jdk-1.4
		dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
		 dev-java/ant-core"

src_install() {
	java-pkg_newjar "bin/${P}.jar"
	use doc && dodoc README.TXT
}
