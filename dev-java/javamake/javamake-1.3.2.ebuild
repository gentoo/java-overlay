# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg

DESCRIPTION="A Make Tool for the Java Language"

HOMEPAGE="http://www.experimentalstuff.com/Technologies/JavaMake/"

SRC_URI="http://www.experimentalstuff.com/data/javamake${PV}.jar"

LICENSE="javamake"

SLOT="0"

KEYWORDS="~x86"

IUSE=""

DEPEND=""

RDEPEND="virtual/jre"

src_unpack() {
	mkdir -p ${S}
	cp ${DISTDIR}/javamake${PV}.jar ${S}/javamake.jar
}
 
src_compile() {
	einfo "Binary ebuild"
}

src_install() {
	java-pkg_dojar javamake.jar
}
