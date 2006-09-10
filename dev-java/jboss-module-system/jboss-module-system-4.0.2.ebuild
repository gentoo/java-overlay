# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4

DESCRIPTION="System module for JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
IUSE=""
SLOT="4"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="dev-java/junit
	=dev-java/java-getopt-1*
	dev-java/log4j
	=dev-java/commons-beanutils-1.6*
	dev-java/commons-codec
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-discovery
	dev-java/commons-fileupload
	dev-java/commons-httpclient
	=dev-java/commons-lang-2.0*
	dev-java/commons-logging
	=dev-java/dom4j-1*
	=dev-java/java-getopt-1*
	=dev-java/jaxen-1.1*
	=dev-java/jboss-module-common-4.0.2*
	=dev-java/jboss-module-jmx-4.0.2*"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPEND}"
