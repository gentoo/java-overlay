# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

inherit jboss-4

DESCRIPTION="Cluster module of JBoss Application Server."
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
IUSE="jikes"
SLOT="4"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="dev-java/commons-codec
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-discovery
	dev-java/commons-fileupload
	=dev-java/commons-httpclient-2*
	=dev-java/commons-lang-2.0*
	dev-java/commons-logging
	=dev-java/bsf-2.3*
	dev-java/log4j
	dev-java/xalan
	dev-java/junit
	dev-java/jgroups
	=dev-java/gnu-regexp-1*
	dev-java/concurrent-util
	=dev-java/jboss-module-j2ee-${PV}*
	=dev-java/jboss-module-common-${PV}*
	=dev-java/jboss-module-system-${PV}*
	=dev-java/jboss-module-naming-${PV}*
	=dev-java/jboss-module-server-${PV}*
	=dev-java/jboss-module-jmx-${PV}*
	=dev-java/jboss-module-messaging-${PV}*
	=dev-java/jboss-module-security-${PV}*
	=dev-java/jboss-module-transaction-${PV}*"
DEPEND=">=virtual/jdk-1.4
	${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"

#src_install() {
	# TODO: investigate
	# output/lib/{jbossha-httpsession.sar,ClusteredHttpSessionEB}
	# because these seem to be directories
#	java-pkg_dojar output/lib/{jbossha,jbossha-client}.jar
#}
