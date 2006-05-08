# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4

DESCRIPTION="Tomcat module of JBoss Application Server"
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
	=www-servers/tomcat-5.5*
	=dev-java/dom4j-1*
	dev-java/jgroups
	dev-java/junit
	dev-java/concurrent-util
	=dev-java/servletapi-2.4*
	=dev-java/jboss-module-j2ee-${PV}*
	=dev-java/jboss-module-system-${PV}*
	=dev-java/jboss-module-security-${PV}*
	=dev-java/jboss-module-server-${PV}*
	=dev-java/jboss-module-common-${PV}*
	=dev-java/jboss-module-jmx-${PV}*
	=dev-java/jboss-module-cluster-${PV}*
	=dev-java/jboss-module-cache-${PV}*
	=dev-java/jboss-module-connector-${PV}*"	
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPEND}"

pkg_setup() {
	if ! has_version ">=www-servers/tomcat-5.5.9"; then
		eerror "Version 5.5.9 or greater is required for this package."
		eerror "Please emerge \">=www-servers/tomcat-5.5.9\" before continuing"
		die
	fi
}
