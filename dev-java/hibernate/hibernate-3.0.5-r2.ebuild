# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/hibernate/hibernate-3.0.5-r2.ebuild,v 1.6 2007/11/02 10:40:55 betelgeuse Exp $

WANT_ANT_TASKS="ant-antlr ant-swing ant-junit"

inherit java-pkg-2 java-ant-2 eutils

MY_PV="3.0"
DESCRIPTION="Hibernate is a powerful, ultra-high performance object / relational persistence and query service for Java."
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
HOMEPAGE="http://www.hibernate.org"
LICENSE="LGPL-2"
# disable jboss until modular jboss is ready
#IUSE="doc jboss"
IUSE="doc"
SLOT="3"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="
	dev-java/ant-core
	=dev-java/antlr-2*
	=dev-java/asm-2.0*
	dev-java/c3p0
	=dev-java/cglib-2.1*
	dev-java/commons-collections
	dev-java/commons-logging
	=dev-java/dom4j-1*
	=dev-java/ehcache-1.1*
	=dev-java/jaxen-1.1*
	dev-java/log4j
	dev-java/oscache
	dev-java/proxool
	=dev-java/swarmcache-1*
	dev-java/jta
	dev-java/sun-jacc-api
	>=dev-java/xerces-2.7"
#	jboss? (
#		=dev-java/jboss-module-cache-4.0*
#		=dev-java/jboss-module-common-4.0*
#		=dev-java/jboss-module-j2ee-4.0*
#		=dev-java/jboss-module-jmx-4.0*
#		=dev-java/jboss-module-system-4.0*
#	)

RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"
DEPEND=">=virtual/jdk-1.4
		${COMMON_DEPEND}"
# TODO fix for Java 1.6... has problems due to JDBC4
JAVA_PKG_NV_DEPEND="=virtual/jdk-1.4* =virtual/jdk-1.5*"

S=${WORKDIR}/${PN}-${MY_PV}

src_unpack() {
	unpack ${A}
	cd ${S}

	# get rid of the lame splash screen
	epatch ${FILESDIR}/${P}-nosplash.patch

#	if ! use jboss; then
		rm src/org/hibernate/cache/JndiBoundTreeCacheProvider.java \
			src/org/hibernate/cache/TreeCache.java \
			src/org/hibernate/cache/TreeCacheProvider.java
#	fi

	cd lib
	rm -v *.jar || die

	local JAR_PACKAGES="ant-core antlr asm-2 c3p0 commons-collections
		commons-logging dom4j-1 ehcache jaxen-1.1 jta
		log4j oscache proxool swarmcache-1.0 sun-jacc-api xerces-2"
	for PACKAGE in ${JAR_PACKAGES}; do
		java-pkg_jar-from ${PACKAGE}
	done
	java-pkg_jar-from cglib-2.1 cglib.jar

#	if use jboss; then
#		java-pkg_jar-from jboss-module-cache-4 jboss-cache.jar
#		java-pkg_jar-from jboss-module-common-4 jboss-common.jar
#		java-pkg_jar-from jboss-module-j2ee-4 jboss-j2ee.jar
#		java-pkg_jar-from jboss-module-jmx-4 jboss-jmx.jar
#		java-pkg_jar-from jboss-module-system-4 jboss-system.jar
#	fi

}

EANT_EXTRA_ARGS="-Ddist.dir=dist"

src_install() {
	java-pkg_dojar dist/hibernate3.jar
	dodoc changelog.txt readme.txt
	use doc && java-pkg_dohtml -r dist/doc/api doc/other doc/reference
}
