# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4

DESCRIPTION="Server module for JBoss Application Server"
GENTOO_CONF="jboss-${PVR}-gentoo.data"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${BASE_URL}/${GENTOO_CONF} ${ECLASS_URI}"
HOMEPAGE="http://www.jboss.org"
LICENSE="LGPL-2"
IUSE="jikes"
SLOT="4"
KEYWORDS="~x86"

COMMON_DEPEND="dev-java/bcel
	=dev-java/commons-beanutils-1.6*
	dev-java/commons-codec
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-discovery
	dev-java/commons-fileupload
	=dev-java/commons-httpclient-2*
	dev-java/commons-lang
	dev-java/commons-logging
	dev-java/log4j
	dev-java/gjt-jpl-pattern
	dev-java/gjt-jpl-util
	=dev-java/java-getopt-1*
	dev-java/wsdl4j
	dev-java/concurrent-util
	dev-java/junit
	dev-java/javacc
	=dev-java/jboss-j2ee-${PV}*
	=dev-java/jboss-common-${PV}*
	=dev-java/jboss-system-${PV}*
	=dev-java/jboss-jmx-${PV}*"
DEPEND=">=virtual/jdk-1.3 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.3 ${COMMON_DEPEND}"
