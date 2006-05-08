# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4

DESCRIPTION="Web Service module of JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
IUSE="jikes"
SLOT="4"
KEYWORDS="~x86"

COMMON_DEPEND="=dev-java/commons-beanutils-1.6*
	dev-java/commons-codec
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-discovery
	dev-java/commons-fileupload
	=dev-java/commons-httpclient-2*
	=dev-java/commons-lang-2.0*
	dev-java/commons-logging
	dev-java/xml-commons-resolver
	=dev-java/xerces-2*
	dev-java/gnu-jaxp
	=dev-java/dom4j-1*
	dev-java/wsdl4j
	=dev-java/gnu-jaf-1*
	dev-java/gnu-javamail
	~dev-java/servletapi-2.4
	=dev-java/jboss-module-common-${PV}*
	=dev-java/jboss-module-j2ee-${PV}*
	=dev-java/jboss-module-jaxrpc-${PV}*
	=dev-java/jboss-module-remoting-${PV}*
	=dev-java/jboss-module-server-${PV}*
	=dev-java/jboss-module-system-${PV}*
	=dev-java/jboss-module-jmx-${PV}*"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPEND}"

src_unpack() {
	jboss-4_src_unpack

	# For some reason, some of server's files are includes in webservice's jars
	mkdir -p ${JBOSS_ROOT}/server/output/classes
	cd ${JBOSS_ROOT}/server/output/classes
	unzip -qq /usr/share/jboss-module-server-${SLOT}/lib/jboss.jar

	cd ${S}
}
