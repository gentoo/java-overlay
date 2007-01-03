# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/hibernate/hibernate-2.1.8.ebuild,v 1.4 2005/07/09 22:26:45 swegener Exp $

inherit java-pkg-2 java-ant-2

DESCRIPTION="Hibernate is a powerful, ultra-high performance object / relational persistence and query service for Java."
SRC_URI="mirror://sourceforge/hibernate/${P}.tar.gz"
HOMEPAGE="http://hibernate.bluemars.net"
LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="~x86 ~amd64"
COMMOND_DEPEND="
		=dev-java/cglib-2.0*
		dev-java/commons-collections
		dev-java/commons-lang
		dev-java/commons-logging
		dev-java/concurrent-util
		>=dev-java/dom4j-1.5
		=dev-java/ehcache-1.1*
		dev-java/odmg
		dev-java/c3p0
		dev-java/commons-pool
		dev-java/commons-dbcp
		=dev-java/jcs-1.2*
		dev-java/proxool
		dev-java/oscache
		=dev-java/swarmcache-1.0*
		=dev-java/jboss-module-j2ee-4.0*
"
		#dev-java/jta
		#dev-java/sun-j2ee-connector-bin
RDEPEND=">=virtual/jre-1.4
		${COMMOND_DEPEND}"
DEPEND=">=virtual/jdk-1.4
		>=dev-java/ant-core-1.5
		${COMMON_DEPEND}"
# TODO fix for Java 1.6... has problems due to JDBC4
JAVA_PKG_NV_DEPEND="=virtual/jdk-1.4* =virtual/jdk-1.5*"

IUSE="doc source"

S=${WORKDIR}/${PN}-${PV:0:3}

src_unpack() {
	unpack ${A}
	cd ${S}
	mv lib old-lib
	mkdir lib
	cd lib
	java-pkg_jar-from jboss-module-j2ee-4

	java-pkg_jar-from ant-core ant.jar
	java-pkg_jar-from cglib-2
	java-pkg_jar-from commons-collections
	java-pkg_jar-from commons-lang
	java-pkg_jar-from commons-logging
	java-pkg_jar-from concurrent-util
	java-pkg_jar-from dom4j-1
	java-pkg_jar-from ehcache
#	java-pkg_jar-from jta
	java-pkg_jar-from odmg

	java-pkg_jar-from c3p0

	java-pkg_jar-from commons-dbcp
	java-pkg_jar-from commons-pool

	# JBoss disabled for now
	# but we'd need jboss-cache and jboss-system, and jmx
	find ${S}/src -name "Tree*" -exec rm {} \;

	java-pkg_jar-from jcs-1.2

	java-pkg_jar-from proxool
	java-pkg_jar-from oscache

	java-pkg_jar-from swarmcache-1.0

	cd ..

	sed -r -i \
		-e '/<splash/d' \
		-e 's/..\/\$\{name\}/dist/g' \
			build.xml
	sed -r -i \
		-e "s/JCSCache/EhCache/g" \
			test/org/hibernate/test/CacheTest.java
}

src_compile() {
	eant jar $(use_doc)
}

src_install() {
	java-pkg_dojar dist/*.jar
	dodoc *.txt
	use doc && java-pkg_dohtml -r dist/doc/*
	# TODO have a IUSE=sample
	insinto /usr/share/doc/${P}/sample
	doins etc/*.xml etc/*.properties etc/*.ccf src/META-INF/ra.xml
	use source && java-pkg_dosrc src/net
}
