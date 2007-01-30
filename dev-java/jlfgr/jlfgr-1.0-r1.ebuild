# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jlfgr/jlfgr-1.0.ebuild,v 1.8 2006/10/05 17:44:51 gustavoz Exp $

inherit java-pkg-2

DESCRIPTION="Java(TM) Look and Feel Graphics Repository"
HOMEPAGE="http://java.sun.com/developer/techDocs/hi/repository/"
SRC_URI="mirror://gentoo/jlfgr-1_0.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=""
S=${WORKDIR}

src_install() {
	java-pkg_newjar jlfgr-1_0.jar ${PN}.jar
}
