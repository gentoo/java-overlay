# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

JAVA_PKG_IUSE="doc source"

inherit java-pkg-2 java-ant-2

MY_PV="2007_03_04"

DESCRIPTION="SwingX-WS contains a set of JavaBeans for interacting with web
services"
HOMEPAGE="https://swingx-ws.dev.java.net"
SRC_URI="http://swingx-ws.dev.java.net/files/documents/5363/51937/${PN}-${MY_PV}-src.zip"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""


CDEPEND="=dev-java/commons-codec-1.3*
		>=dev-java/commons-httpclient-3.0.1
		>=dev-java/commons-logging-1.0
		dev-java/jdom
		dev-java/jtidy
		dev-java/json
		>=dev-java/rome-0.8
		dev-java/xerces
		dev-java/swingx
		dev-java/swing-worker"

DEPEND=">=virtual/jdk-1.5
		>=dev-java/ant-core-1.7
		app-arch/unzip
		${CDEPEND}"

RDEPEND=">=virtual/jre-1.5
		${CDEPEND}"

S="${WORKDIR}/swingx-ws-${MY_PV}-src"

src_unpack() {
	unpack "${A}"
	cd "${S}/lib/optional"
	rm *.jar
	java-pkg_jar-from commons-codec commons-codec.jar commons-codec-1.3.jar
	java-pkg_jar-from commons-httpclient-3 commons-httpclient.jar commons-httpclient-3.0.1.jar
	java-pkg_jar-from commons-logging commons-logging.jar commons-logging-1.1.jar
	java-pkg_jar-from jdom-1.0 jdom.jar
	java-pkg_jar-from json
	java-pkg_jar-from jtidy Tidy.jar jtidy-r7.jar
	java-pkg_jar-from rome rome.jar rome-0.8.jar
	java-pkg_jar-from xerces-2

	cd "${S}/lib/cobundle"
	rm *.jar
	java-pkg_jar-from swingx
	java-pkg_jar-from swing-worker
}

src_install() {
	java-pkg_dojar dist/*.jar
	use doc && java-pkg_dojavadoc dist/javadoc
}

