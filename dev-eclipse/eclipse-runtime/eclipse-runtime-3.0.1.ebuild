# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit eutils java-pkg

DESCRIPTION="Eclipse runtime Libraries"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://misc.ajiaojr.org/gentoo/eclipse-runtime-${PV}.tar.bz2"
LICENSE="CPL-1.0 LGPL-2.1 MPL-1.1"
KEYWORDS="x86"
SLOT="3.0"

IUSE="gnome mozilla"

RDEPEND="=dev-eclipse/eclipse-osgi-3.0*"

DEPEND="${RDEPEND}
	>=virtual/jdk-1.4
	dev-java/ant"

src_unpack() {
	unpack ${A}
	
	cd ${S}/lib
	rm -f *.jar

	java-pkg_jar-from eclipse-osgi-3.0
}

src_compile() {
	ant || die "Failed to create jar"
}

src_install() {
	java-pkg_dojar dist/*.jar || die "Installation  failed"
}

