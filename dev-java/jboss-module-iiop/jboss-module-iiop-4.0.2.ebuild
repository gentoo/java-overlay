# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit jboss-4

DESCRIPTION="IIOP module of JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
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
	dev-java/gnu-javamail
	=dev-java/jboss-module-j2ee-${PV}*
	=dev-java/jboss-module-common-${PV}*
	=dev-java/jboss-module-system-${PV}*
	=dev-java/jboss-module-jmx-${PV}*"
DEPEND=">=virtual/jdk-1.4
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"

src_compile() {
	eant 
}
