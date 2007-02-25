# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Apache WSS4J is an implementation of the OASIS Web Services Security (WS-Security)"
HOMEPAGE="http://ws.apache.org/wss4j/index.html"
SRC_URI="http://dev.gentooexperimental.org/~kiorky/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 "
IUSE="doc source"

DEPEND=">=virtual/jdk-1.5
		source? ( app-arch/zip )
		=dev-java/xerces-2.6*
		=dev-java/xml-commons-external-1.3*
		dev-java/apache-addressing
		=dev-java/xml-security-1.3*
		dev-java/xalan
		=dev-java/neethi-2*
		=dev-java/wsdl4j-1.5*
		=dev-java/junit-3.8*
		dev-java/commons-logging
		=dev-java/commons-httpclient-3*
		dev-java/commons-discovery
		dev-java/ws-policy
		dev-java/commons-codec
		dev-java/bcprov
		=www-servers/axis-1*
		dev-java/log4j
		dev-java/opensaml
		"
RDEPEND="${DEPEND} >=virtual/jre-1.5"

EANT_BUILD_TARGET="compile jar"
EANT_DOC_TARGET="javadocs"
EANT_GENTOO_CLASSPATH="apache-addressing,xml-security-1.3,xalan,wsdl4j,junit,commons-httpclient-3,commons-logging,commons-discovery,commons-codec,bcprov,axis-1,opensaml,log4j,neethi,ws-policy"

src_unpack(){
	unpack ${A}

	epatch "${FILESDIR}/WSSPolicyProcessor.java.patch"
	epatch "${FILESDIR}/build.xml.patch"

	cd ${S}/endorsed || die "cd failed"
	java-pkg_jar-from xerces-2.6
	java-pkg_jar-from xml-commons-external-1.3

	cd ${S}/lib || die "cd failed"
	java-pkg_jar-from apache-addressing    addressing.jar         addressing-1.0.jar
	java-pkg_jar-from xml-security-1.3     xmlsec.jar             xmlsec-1.3.0.jar
	java-pkg_jar-from xalan                xalan.jar              xalan-2.7.0.jar
	java-pkg_jar-from xalan                serializer.jar         serializer-2.7.0.jar
	java-pkg_jar-from wsdl4j               wsdl4j.jar             wsdl4j-1.5.1.jar
	java-pkg_jar-from junit                junit.jar              junit-3.8.1.jar
	java-pkg_jar-from commons-logging      commons-logging.jar    commons-logging-1.0.4.jar
	java-pkg_jar-from commons-httpclient-3 commons-httpclient.jar commons-httpclient-3.0-rc2.jar
	java-pkg_jar-from commons-discovery    commons-discovery.jar  commons-discovery-0.2.jar
	java-pkg_jar-from commons-codec        commons-codec.jar      commons-codec-1.3.jar
	java-pkg_jar-from bcprov               bcprov.jar             bcprov-jdk13-132.jar
	java-pkg_jar-from bcprov               bcprov.jar             bcprov-jdk15-132.jar
	java-pkg_jar-from axis-1			   axis-ant.jar           axis-ant-1.4.jar
	java-pkg_jar-from axis-1			   axis.jar               axis-1.4.jar
	java-pkg_jar-from axis-1			   jaxrpc.jar             axis-jaxrpc-1.4.jar
	java-pkg_jar-from axis-1			   saaj.jar               axis-saaj-1.4.jar
	java-pkg_jar-from log4j                log4j.jar              log4j-1.2.9.jar
	java-pkg_jar-from opensaml             opensaml.jar           opensaml-1.0.1.jar
	java-pkg_jar-from neethi-2             neethi.jar             neethi-SNAPSHOT.jar
	for i in $(find ${S}/build*xml);do
		java-ant_rewrite-classpath "$i"
	done
}

src_install() {
	java-pkg_newjar "${S}/build/wss4j-${PV}.jar" "${PN}.jar"
	use doc && java-pkg_dojavadoc "${S}/build/doc"
	use source && java-pkg_dosrc  "${S}/src"
}
