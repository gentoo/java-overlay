# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit jboss-4

DESCRIPTION="JMX module of JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
IUSE=""
SLOT="4"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="=dev-java/jboss-module-common-${PV}*
	dev-java/bcel
	=dev-java/commons-beanutils-1.6*
	dev-java/commons-codec
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-discovery
	dev-java/commons-fileupload
	=dev-java/commons-httpclient-2*
	dev-java/commons-logging
	dev-java/log4j
	dev-java/xalan
	=dev-java/xerces-2*
	=dev-java/dom4j-1*
	=dev-java/jaxen-1.1*
	=dev-java/gnu-regexp-1*
	dev-java/junit
	dev-java/concurrent-util
	=dev-java/crimson-1*
	dev-java/gnu-jaxp
	dev-java/sax"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPEND}"

ANT_TARGET="output"
