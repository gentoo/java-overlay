# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit jboss-4

DESCRIPTION="Security module of JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
IUSE=""
SLOT="4"
KEYWORDS="~amd64 ~x86"

# this doesn't like javacc-4 apparently, but depending on =3* would create a
# up/downgrade cycle
COMMON_DEPEND="dev-java/log4j
	=dev-java/dom4j-1*
	dev-java/junit
	dev-db/hsqldb
	dev-java/concurrent-util
	=dev-java/jboss-module-j2ee-${PV}*
	=dev-java/jboss-module-common-${PV}*
	=dev-java/jboss-module-system-${PV}*
	=dev-java/jboss-module-naming-${PV}*
	=dev-java/jboss-module-server-${PV}*
	=dev-java/jboss-module-jmx-${PV}*"
# FIXME doesn't like 1.6
DEPEND="|| ( =virtual/jdk-1.4* =virtual/jdk-1.5* ) ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPEND}"

pkg_setup() {
	if has_version ">=dev-java/javacc-4.0"; then
		die "${PN} breaks with javacc-4.0"
	fi
	java-pkg-2_pkg_setup
}
