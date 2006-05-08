# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4

DESCRIPTION="Console module of JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
IUSE="jikes"
SLOT="4"
KEYWORDS="~x86"

COMMON_DEPEND="
	=dev-java/java-getopt-1*
	dev-java/log4j
	dev-java/commons-codec
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-discovery
	dev-java/commons-fileupload
	=dev-java/commons-httpclient-2*
	=dev-java/commons-lang-2.0*
	dev-java/commons-logging
	=dev-java/dom4j-1*
	=dev-java/jaxen-1.1*
	dev-java/bsh
	~dev-java/servletapi-2.4
	dev-java/jfreechart
	dev-java/jcommon
	dev-java/trove
	=dev-java/jboss-module-common-${PV}*
	=dev-java/jboss-module-jmx-${PV}*
	=dev-java/jboss-module-management-${PV}*
	=dev-java/jboss-module-server-${PV}*
	=dev-java/jboss-module-messaging-${PV}*
	=dev-java/jboss-module-system-${PV}*
	=dev-java/jboss-module-varia-${PV}*
	dev-java/jboss-aop"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPEND}"
