# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/maven-bin/maven-bin-1.0.2.ebuild,v 1.1 2006/01/19 03:03:11 nichoj Exp $

inherit base

MY_PN=${PN/-bin}
MY_PV=${PV/_/-}
MY_PV=${MY_PV/beta/beta-}
MY_P=${MY_PN}-${MY_PV}
DESCRIPTION="Project Management and Comprehension Tool for Java"
SRC_URI="mirror://apache/maven/binaries/${MY_P}.tar.bz2"
HOMEPAGE="http://maven.apache.org/"
LICENSE="Apache-2.0"
SLOT="1.0"
KEYWORDS="~x86 ~ppc ~amd64"
DEPEND=">=virtual/jdk-1.3"
RDEPEND=">=virtual/jdk-1.3"
IUSE=""
RESTRICT="nomirror"

S="${WORKDIR}/${MY_P}"
MAVEN=${PN}-${SLOT}
MAVEN_HOME="/usr/share/${MAVEN}"
MAVEN_BIN="${MAVEN_HOME}/bin"

src_compile() { :; }

src_install() {
	dodir ${MAVEN_HOME}
	insinto ${MAVEN_HOME}
	doins -r bin lib *.xsd plugins

	dodir ${MAVEN_BIN}
	exeinto ${MAVEN_BIN}
	doexe ${FILESDIR}/${MY_PN}

	dodir /usr/bin
	dosym ${MAVEN_BIN}/${MY_PN} /usr/bin/${MY_PN} || die sym failed
}
