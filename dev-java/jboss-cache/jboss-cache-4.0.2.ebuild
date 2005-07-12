# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4

DESCRIPTION="Cache module of JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${BASE_URL}/${GENTOO_CONF} ${ECLASS_URI}"
HOMEPAGE="http://www.jboss.org"
LICENSE="LGPL-2"
IUSE="jikes"
SLOT="4"
KEYWORDS="~x86"

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
	dev-java/jmx
	dev-java/xdoclet
	=dev-java/jboss-j2ee-${PV}*
	=dev-java/jboss-common-${PV}*
	dev-java/jboss-aop
	=dev-java/jboss-system-${PV}*
	=dev-java/jboss-naming-${PV}*
	=dev-java/jboss-messaging-${PV}*
	=dev-java/jboss-server-${PV}*
	=dev-java/jboss-security-${PV}*
	=dev-java/jboss-jmx-${PV}*
	=dev-java/jboss-management-${PV}*
	=dev-java/jboss-transaction-${PV}*
	=dev-java/jboss-remoting-${PV}*
"	
DEPEND=">=virtual/jdk-1.3 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.3 ${COMMON_DEPEND}"
