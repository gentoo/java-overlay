# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/eclipse-ecj/eclipse-ecj-3.1-r2.ebuild,v 1.3 2006/03/10 19:48:08 corsair Exp $

inherit eutils java-pkg

MY_PN=${PN##*-}

DESCRIPTION="Eclipse Compiler for Java"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://dev.gentoo.org/~nichoj/distfiles/${P}.tar.bz2"
LICENSE="EPL-1.0"
KEYWORDS="~amd64 ~x86"
SLOT="3.2"

IUSE=""

RDEPEND=">=virtual/jre-1.4"

DEPEND="${RDEPEND}
	>=virtual/jdk-1.4
	dev-java/ant-core"

src_compile() {
	ant -f compilejdtcorewithjavac.xml || die "Failed to build with javac"
	ant -lib ecj.jar -f compilejdtcore.xml || die "Failed to build with ecj"
}

src_install() {
	java-pkg_dojar ecj.jar
}

