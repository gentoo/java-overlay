# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4

DESCRIPTION="Server module for JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
IUSE=""
SLOT="4"
KEYWORDS="~amd64 ~x86"

# unhappy on amd64? or is javacc-4.0 evil?
COMMON_DEPEND="dev-java/bcel
	=dev-java/commons-beanutils-1.6*
	dev-java/commons-codec
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-discovery
	dev-java/commons-fileupload
	=dev-java/commons-httpclient-2*
	=dev-java/commons-lang-2.0*
	dev-java/commons-logging
	dev-java/log4j
	dev-java/gjt-jpl-pattern
	dev-java/gjt-jpl-util
	=dev-java/java-getopt-1*
	dev-java/wsdl4j
	dev-java/concurrent-util
	dev-java/junit
	dev-java/javacc
	=dev-java/jboss-module-j2ee-${PV}*
	=dev-java/jboss-module-common-${PV}*
	=dev-java/jboss-module-system-${PV}*
	=dev-java/jboss-module-transaction-${PV}*
	=dev-java/jboss-module-naming-${PV}*
	=dev-java/jboss-module-jmx-${PV}*"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPEND}"

# TODO fix compilations with Java 1.6 due to JDBC4 
JAVA_PKG_NV_DEPEND="=virtual/jdk-1.4* =virtual/jdk-1.5*"
# TODO need to increase maximum stack size on amd64 w/ blackdown, ie
# ANT_OPTS=-Xmx640m
