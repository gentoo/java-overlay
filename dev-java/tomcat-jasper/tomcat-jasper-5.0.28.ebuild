# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="Jasper 2 is the Tomcat JSP Engine"
HOMEPAGE="http://jakarta.apache.org/tomcat"
SRC_URI="mirror://apache/jakarta/tomcat-5/v${PV}/src/jakarta-tomcat-${PV}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="~x86 ~amd64"
IUSE="doc source"

DEPEND="=virtual/jdk-1.4*
	=dev-java/servletapi-2.4*
	=dev-java/xerces-1.3*
	>=dev-java/xerces-2.7
	dev-java/xml-commons
	dev-java/commons-collections
	dev-java/commons-daemon
	dev-java/commons-el
	dev-java/commons-logging
	dev-java/commons-launcher
	jikes? ( dev-java/jikes )
	source? ( app-arch/zip )
"

RDEPEND="${DEPEND}
	>=virtual/jdk-1.4
"

S=${WORKDIR}/jakarta-tomcat-${PV}-src/jakarta-tomcat-jasper/jasper2

src_unpack() {
	unpack ${A}
	cd ${S}

	# Setup build.properties
	echo "servlet-api.jar=$(java-pkg_getjar servletapi-2.4 servlet-api.jar)" >> build.properties
	echo "jsp-api.jar=$(java-pkg_getjar servletapi-2.4 jsp-api.jar)" >> build.properties
	echo "ant.jar.jar=$(java-pkg_getjar ant-core ant.jar)" >> build.properties
	echo "xerces.jar=$(java-pkg_getjar xerces-1.3 xerces.jar)" >> build.properties
	echo "xercesImpl.jar=$(java-pkg_getjar xerces-2 xercesImpl.jar)" >> build.properties
	echo "xml-apis.jar=$(java-pkg_getjar xml-commons xml-apis.jar)" >> build.properties
	echo "commons-el.jar=$(java-pkg_getjar commons-el commons-el.jar)" >> build.properties
	echo "commons-collections.jar=$(java-pkg_getjar commons-collections	commons-collections.jar)" >> build.properties
	echo "commons-logging.jar=$(java-pkg_getjar commons-logging commons-logging.jar)" >> build.properties
	echo "commons-daemon-launcher=$(java-pkg_getjar commons-daemon commons-daemon.jar)" >> build.properties
	echo "commons-launcher.jar=$(java-pkg_getjar commons-launcher commons-launcher.jar)" >> build.properties
}

src_compile() {
	eant build-main $(use_doc javadoc)
}

src_install() {
	java-pkg_dojar ${S}/build/shared/lib/jasper-*.jar

	use doc && java-pkg_dohtml -r ${S}/build/javadoc
	use source && java-pkg_dosrc src/share/*
}
