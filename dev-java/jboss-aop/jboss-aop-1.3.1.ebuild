# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

MY_P="${PN}_${PV}"
DESCRIPTION="JBoss AOP is a 100% Pure Java aspected oriented framework usuable in any programming environment or tightly integrated with our application server."
HOMEPAGE="http://www.jboss.org/products/aop"
SRC_URI="mirror://sourceforge/jboss/${MY_P}.zip"

# TODO: verify that LICENSE is right
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=virtual/jdk-1.4
	app-arch/unzip"
RDEPEND=">=virtual/jre-1.4"

S=${WORKDIR}/${MY_P}

src_compile() {
	ewarn "This is a binary package for now, just so we can pretend like"
	ewarn "we have all the dependencies for JBoss AS"
}

src_install() {
	java-pkg_dojar lib/jboss-aspect-library.jar lib/jboss-aop.jar
}
