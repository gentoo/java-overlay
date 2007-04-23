# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

WANT_ANT_TASKS="ant-swing ant-junit ant-antlr"

inherit java-pkg-2 java-ant-2 eutils

MY_PV=${PV/_rc/.cr}
MY_P="${PN}-${MY_PV}"
DESCRIPTION="Hibernate is a powerful, ultra-high performance object / relational persistence and query service for Java."
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.ga.tar.gz"
HOMEPAGE="http://www.hibernate.org"
LICENSE="LGPL-2"
IUSE="doc jboss source"
SLOT="3.2"
KEYWORDS="~x86 ~amd64"

COMMON_DEPEND="
	dev-java/ant-tasks
	dev-java/antlr
	=dev-java/asm-1.5*
	dev-java/c3p0
	=dev-java/cglib-2.1*
	dev-java/commons-collections
	dev-java/commons-logging
	=dev-java/dom4j-1*
	>=dev-java/ehcache-1.2.4
	=dev-java/jaxen-1.1*
	dev-java/log4j
	dev-java/oscache
	dev-java/proxool
	=dev-java/swarmcache-1*
	jboss? (
		dev-java/jboss-cache
		=dev-java/jboss-module-common-4.0*
		=dev-java/jboss-module-j2ee-4.0*
		=dev-java/jboss-module-jmx-4.0*
		=dev-java/jboss-module-system-4.0*
	)
	!jboss? ( dev-java/sun-jacc-api )
	dev-java/jgroups
	=dev-java/javassist-3*
	>=dev-java/xerces-2.7
	dev-java/jta"
RDEPEND=">=virtual/jre-1.4
	${COMMON_DEPEND}"
# FIXME doesn't like  Java 1.6's JDBC API
DEPEND="|| (
		=virtual/jdk-1.4*
		=virtual/jdk-1.5*
	)
	dev-java/ant-core
	${COMMON_DEPEND}"

S="${WORKDIR}/${PN}-${SLOT}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if ! use jboss; then
		rm src/org/hibernate/cache/JndiBoundTreeCacheProvider.java \
			src/org/hibernate/cache/OptimisticTreeCache.java \
			src/org/hibernate/cache/OptimisticTreeCacheProvider.java \
			src/org/hibernate/cache/TreeCache.java \
			src/org/hibernate/cache/TreeCacheProvider.java || die "failed to remove jboss files"
	fi


	cd "${S}/lib"
	rm *.jar

	local JAR_PACKAGES="c3p0 commons-collections javassist-3
		commons-logging dom4j-1 ehcache-1.2 jaxen-1.1
		log4j oscache proxool swarmcache-1.0 xerces-2 jgroups jta"
	for PACKAGE in ${JAR_PACKAGES}; do
		java-pkg_jar-from ${PACKAGE}
	done
	java-pkg_jar-from cglib-2.1 cglib.jar

	if use jboss; then
		java-pkg_jar-from jboss-cache jboss-cache.jar
		java-pkg_jar-from jboss-module-common-4 jboss-common.jar
		java-pkg_jar-from jboss-module-j2ee-4 jboss-j2ee.jar
		java-pkg_jar-from jboss-module-jmx-4 jboss-jmx.jar
		java-pkg_jar-from jboss-module-system-4 jboss-system.jar
	else
		# this is only the jacc api, just so we can get things compiled.
		# the things that needs this likely wouldn't actually be used at runtime
		# unless you're running in a container, like jboss
		java-pkg_jar-from sun-jacc-api
	fi

	java-pkg_jar-from ant-tasks ant-antlr.jar
	java-pkg_jar-from antlr
	java-pkg_jar-from ant-core ant.jar
	java-pkg_jar-from asm-1.5 asm.jar
	java-pkg_jar-from asm-1.5 asm-attrs.jar

}
src_compile() {
	export ANT_OPTS="-Xmx1G"
	#local extra_targets=""
	#if ! use amd64; then
	#	extra_targets="$(use_doc)"
	#fi
	eant jar -Dnosplash=true -Ddist.dir=dist #${extra_targets}
}

src_install() {
	java-pkg_dojar build/*.jar
	dodoc changelog.txt readme.txt
	if use doc; then
		java-pkg_dojavadoc doc/api
		dohtml -r doc/other 
		dohtml -r doc/reference
	fi
	use source && java-pkg_dosrc src/*
}
