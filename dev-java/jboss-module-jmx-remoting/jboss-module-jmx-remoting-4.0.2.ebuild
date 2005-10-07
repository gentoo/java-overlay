# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4

DESCRIPTION="JMX-Remoting module of JBoss Application Server"
GENTOO_CONF="jboss-${PV}-gentoo-r2.data"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${BASE_URL}/${GENTOO_CONF} ${ECLASS_URI}"
HOMEPAGE="http://www.jboss.org"
LICENSE="LGPL-2"
IUSE="jikes"
SLOT="4"
KEYWORDS="~x86"

COMMON_DEPEND="dev-java/log4j
	dev-java/concurrent-util
	=dev-java/jboss-module-jmx-${PV}*
	=dev-java/jboss-module-remoting-${PV}*"
DEPEND=">=virtual/jdk-1.3 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.3 ${COMMON_DEPEND}"

ANT_TARGET="output"
