# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/hibernate/hibernate-3.0_rc1.ebuild,v 1.4 2005/03/23 00:42:40 st_lim Exp $

inherit java-pkg-2 java-ant-2 eutils

MY_PV="3.1"
DESCRIPTION="Hibernate is a powerful, ultra-high performance object / relational persistence and query service for Java."
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
HOMEPAGE="http://www.hibernate.org"
LICENSE="LGPL-2"
IUSE="doc jboss source"
SLOT="3.1"
KEYWORDS="~x86 ~amd64"

COMMON_DEPEND="
	dev-java/antlr
	=dev-java/asm-2*
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
	jboss? ( 
		=dev-java/jboss-module-cache-4.0*
		=dev-java/jboss-module-common-4.0*
		=dev-java/jboss-module-j2ee-4.0*
		=dev-java/jboss-module-jmx-4.0*
		=dev-java/jboss-module-system-4.0*
	)
	!jboss? (
		dev-java/jta
		dev-java/sun-jacc-api
	)
	dev-java/jgroups
	>=dev-java/xerces-2.7"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"
# FIXME doesn't like  Java 1.6's JDBC API
DEPEND="|| (
		=virtual/jdk-1.4*
		=virtual/jdk-1.5*
	)
	dev-java/ant
	${COMMON_DEPEND}"

S="${WORKDIR}/${PN}-${MY_PV}"

src_unpack() {
	unpack ${A}
	cd ${S}

	if ! use jboss; then
		rm src/org/hibernate/cache/JndiBoundTreeCacheProvider.java \
			src/org/hibernate/cache/TreeCache.java \
			src/org/hibernate/cache/TreeCacheProvider.java
	fi

	cd lib
	rm *.jar

	local JAR_PACKAGES="asm-2 c3p0 commons-collections 
		commons-logging dom4j-1 ehcache jaxen-1.1
		log4j oscache proxool swarmcache-1.0 xerces-2 jgroups"
	for PACKAGE in ${JAR_PACKAGES}; do
		java-pkg_jar-from ${PACKAGE}
	done
	java-pkg_jar-from cglib-2.1 cglib.jar

	if use jboss; then
		java-pkg_jar-from jboss-module-cache-4 jboss-cache.jar
		java-pkg_jar-from jboss-module-common-4 jboss-common.jar
		java-pkg_jar-from jboss-module-j2ee-4 jboss-j2ee.jar
		java-pkg_jar-from jboss-module-jmx-4 jboss-jmx.jar
		java-pkg_jar-from jboss-module-system-4 jboss-system.jar
	else
		java-pkg_jar-from jta
		java-pkg_jar-from sun-jacc-api
	fi
	java-pkg_jar-from ant-tasks ant-antlr.jar
	java-pkg_jar-from antlr
	java-pkg_jar-from ant-core ant.jar

}
src_compile() {
	eant jar -Ddist.dir=dist $(use_doc)
}

src_install() {
	java-pkg_dojar dist/hibernate3.jar
	dodoc changelog.txt readme.txt
	use doc && java-pkg_dohtml -r dist/doc/api doc/other doc/reference
	use source && java-pkg_dosrc src/*
}
