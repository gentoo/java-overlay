# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2 versionator

MY_PV=$(replace_version_separator 2 '')
MY_P="${PN}-${MY_PV}-src"
DESCRIPTION="jUDDI is an open source Java implementation of the Universal Description, Discovery, and Integration (UDDI) specification for Web Services."
HOMEPAGE="http://ws.apache.org/juddi/"
SRC_URI="http://archive.apache.org/dist/ws/${PN}/0_9RC4/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86"
IUSE="doc"

# TODO claims to be >= 1.3.1, but needs testing

# Limits JDK to 1.4 and 1.5 because doc cannot be built with jdk 1.6 because of 'enum' errors
DEPEND="|| ( =virtual/jdk-1.4* =virtual/jdk-1.5* )
	dev-java/ant-core"
RDEPEND=">=virtual/jre-1.4
	=dev-java/servletapi-2.4*
	=dev-java/gnu-jaf-1*
	=www-servers/axis-1*
	dev-java/commons-collections
	dev-java/commons-dbcp
	dev-java/commons-discovery
	dev-java/commons-logging
	dev-java/commons-pool
	dev-java/log4j
	dev-java/wsdl4j"
S="${WORKDIR}/${MY_P}"

SERVLET_API="servletapi-2.4 servlet-api.jar"
ACTIVATION="gnu-jaf-1"
AXIS="axis-1"
COMMONS_COLLECTIONS="commons-collections"
COMMONS_DBCP="commons-dbcp"
COMMONS_DISCOVERY="commons-discovery"
COMMONS_LOGGING="commons-logging"
COMMONS_POOL="commons-pool"
LOG4J="log4j log4j.jar"
WSDL4J="wsdl4j wsdl4j.jar"


src_unpack() {
	unpack ${A}
	mkdir ${S}/lib

	cd ${S}/lib
	java-pkg_jar-from ${SERVLET_API}
	java-pkg_jar-from ${ACTIVATION}

#	einfo "Fixing jars in webapp/WEB-INF/lib/"
	cd ${S}/webapp/WEB-INF/lib
	java-pkg_jar-from ${AXIS}
	java-pkg_jar-from ${COMMONS_COLLECTIONS}
	java-pkg_jar-from ${COMMONS_DBCP}
	java-pkg_jar-from ${COMMONS_DISCOVERY}
	java-pkg_jar-from ${COMMONS_POOL}
	java-pkg_jar-from ${LOG4J} log4j-1.2.8.jar
	java-pkg_jar-from ${WSDL4J}
}

src_compile() {
	eant jar war $(use_doc -Djavadoc.dir=./build/docs/api javadoc)
}

src_install() {
	java-pkg_dojar build/*.jar
	java-pkg_dowar build/*.war
	dodoc README

	if use doc; then
		java-pkg_dohtml -r build/docs/api
	fi
}
