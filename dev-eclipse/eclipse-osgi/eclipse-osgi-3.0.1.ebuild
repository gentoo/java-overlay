# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

inherit java-pkg

DESCRIPTION="Eclipse OSGI libraries"
HOMEPAGE="http://www.eclipse.org/"
SRC_URI="http://misc.ajiaojr.org/gentoo/eclipse-osgi-${PV}.tar.bz2"
LICENSE="CPL-1.0 LGPL-2.1 MPL-1.1"
KEYWORDS="x86"
SLOT="3.0"

IUSE=""

RDEPEND=">=virtual/jre-1.4"

DEPEND="${RDEPEND}
	>=virtual/jdk-1.4
	dev-java/ant-core"

src_compile() {
	ant || die "Failed to create jar"
}

src_install() {
	java-pkg_dojar dist/*.jar || die "Installation failed"
}
