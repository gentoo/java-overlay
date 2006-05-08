# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4

DESCRIPTION="Cache module of JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
IUSE="jikes"
SLOT="4"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="
	dev-java/log4j
	dev-java/xalan
	=dev-java/bsf-2.3*
	=dev-java/gnu-regexp-1*
	dev-java/jgroups
	dev-java/junit
	dev-java/concurrent-util
	dev-db/db-je
	=dev-java/crimson-1*
	dev-java/gnu-jaxp
	=dev-java/mx4j-3.0*
	dev-java/xdoclet
	=dev-java/jboss-module-j2ee-${PV}*
	=dev-java/jboss-module-common-${PV}*
	dev-java/jboss-aop
	=dev-java/jboss-module-system-${PV}*
	=dev-java/jboss-module-naming-${PV}*
	=dev-java/jboss-module-messaging-${PV}*
	=dev-java/jboss-module-server-${PV}*
	=dev-java/jboss-module-security-${PV}*
	=dev-java/jboss-module-jmx-${PV}*
	=dev-java/jboss-module-management-${PV}*
	=dev-java/jboss-module-transaction-${PV}*
	=dev-java/jboss-module-remoting-${PV}*
"	
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPEND}"
