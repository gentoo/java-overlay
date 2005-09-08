# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="A CVS client protocol in Java"
HOMEPAGE="http://javacvs.netbeans.org/index.html"
SRC_URI="http://javacvs.netbeans.org/files/documents/51/116/cvslib_36.jar"

LICENSE=""
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="virtual/jdk"
RDEPEND="virtual/jre"

src_unpack() {
	ewarn "This is a binary package, until the source can be found"
}

src_install() {
	java-pkg_newjar ${DISTDIR}/cvslib_36.jar cvslib.jar
}
