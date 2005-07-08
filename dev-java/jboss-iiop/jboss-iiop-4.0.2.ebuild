# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit jboss-4

DESCRIPTION="IIOP module of JBoss Application Server"
GENTOO_CONF="jboss-${PVR}-gentoo.data"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${BASE_URL}/${GENTOO_CONF} ${ECLASS_URI}"
HOMEPAGE="http://www.jboss.org"
LICENSE="LGPL-2"
# disabling jikes because it gives a semantic error I don't know how to fix
#IUSE="jikes"
IUSE=""
SLOT="4"
KEYWORDS="~x86"

COMMON_DEPEND="
	=dev-java/avalon-framework-4.1*
	=dev-java/avalon-logkit-1.2*
	dev-java/log4j
	dev-java/junit
	dev-java/sun-javamail-bin
	=dev-java/jboss-j2ee-${PV}*
	=dev-java/jboss-common-${PV}*
	=dev-java/jboss-system-${PV}*
	=dev-java/jboss-jmx-${PV}*"
DEPEND=">=virtual/jdk-1.3
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.3
	${COMMON_DEPEND}"

src_compile() {
	cd ${S}

	ant || die "Build script failed"
}
