# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/excalibur-logger/excalibur-logger-2.1.ebuild,v 1.2 2006/12/22 18:12:09 betelgeuse Exp $

EXCALIBUR_MODULES="
	${PN}-api
	${PN}-impl"

EXCALIBUR_MODULE_USES_PV="false"

EXCALIBUR_TESTS="true"

inherit excalibur-multi

SLOT="0"
KEYWORDS="~x86"

RDEDEND="=www-servers/jetty-5*
	dev-java/tomcat-jasper
	dev-java/plexus-component-api
	dev-java/plexus-utils
	dev-java/cornerstone-threads
	dev-java/cornerstone-sockets
	dev-java/excalibur-thread"
DEPEND="${RDEPEND}"

S=${WORKDIR}

EXCALIBUR_JAR_FROM="jetty-5 tomcat-jasper-2 plexus-component-api excalibur-thread cornerstone-threads cornerstone-sockets"

EXCALIBUR_TEST_JAR_FROM="junit junitperf"

src_unpack(){
	excalibur-multi_src_unpack
	epatch "${FILESDIR}"/build.xml.patch
}

