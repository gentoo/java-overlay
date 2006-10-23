# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit jboss-4

DESCRIPTION="Common module of JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo-r1.tar.bz2 ${ECLASS_URI}"
MY_A="${MY_A/${P}-gentoo/${P}-gentoo-r1}"
IUSE=""
KEYWORDS="~amd64 ~x86"

# FIXME uh, apparently this doesn't like newer xerces.
COMMON_DEPEND="=dev-java/bsf-2.3*
	dev-java/xml-commons-resolver
	dev-java/xalan
	=dev-java/xerces-2.6.2*
	=dev-java/commons-beanutils-1.6*
	dev-java/commons-codec
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-discovery
	dev-java/commons-fileupload
	=dev-java/commons-httpclient-2*
	=dev-java/commons-lang-2.0*
	dev-java/commons-logging
	dev-java/jakarta-slide-webdavclient
	=dev-java/gnu-regexp-1*
	dev-java/gnu-jaxp
	=dev-java/jaxen-1.1*
	dev-java/concurrent-util
	dev-java/log4j
	=dev-java/dtdparser-1.21*"
DEPEND="=virtual/jdk-1.4*
	dev-java/ant-core
	dev-java/ant-tasks
	dev-java/junit
	${COMMON_DEPEND}
"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"
