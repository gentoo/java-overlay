# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/jlfgr/jlfgr-1.0.ebuild,v 1.8 2006/10/05 17:44:51 gustavoz Exp $

inherit versionator java-pkg-2

MY_PV=$(replace_all_version_separators '_')
DESCRIPTION="Java(TM) Look and Feel Graphics Repository"
HOMEPAGE="http://java.sun.com/developer/techDocs/hi/repository/"
SRC_URI="mirror://gentoo/jlfgr-${MY_PV}.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86 ~ppc ~amd64"
IUSE=""

DEPEND="app-arch/unzip"
RDEPEND=""
S=${WORKDIR}

src_install() {
	java-pkg_newjar jlfgr-${MY_PV}.jar ${PN}.jar
}
