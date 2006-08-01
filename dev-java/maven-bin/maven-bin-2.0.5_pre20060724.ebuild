# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/maven-bin/maven-bin-2.0.4.ebuild,v 1.1 2006/07/01 14:55:23 nichoj Exp $

# doesn't need to anyherit any java eclasses, since it's not building
# and doesn't use any of the functions

MY_PN=${PN%%-bin}
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Project Management and Comprehension Tool for Java"
SRC_URI="http://maven.zones.apache.org/~maven/builds/branches/maven-2.0.x/m2-20060724.111501.tar.gz"
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="2.0"
KEYWORDS="~amd64 ~ppc ~x86"

RDEPEND=">=virtual/jdk-1.3"

IUSE=""

S="${WORKDIR}/${MY_P}"

MAVEN=${PN}-${SLOT}
MAVEN_SHARE="/usr/share/${MAVEN}"

src_unpack() {
	unpack ${A}

	rm ${S}/bin/*.bat
}

# TODO we should use jars from packages, instead of what is bundled
src_install() {
	dodir ${MAVEN_SHARE}
	cp -Rp bin conf core lib ${D}/${MAVEN_SHARE}

	dodoc NOTICE.txt README.txt

	dodir /usr/bin
	dosym ${MAVEN_SHARE}/bin/mvn /usr/bin/mvn
}
