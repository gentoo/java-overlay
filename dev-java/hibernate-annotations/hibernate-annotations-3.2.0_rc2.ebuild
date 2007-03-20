# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

MY_PV=${PV/_rc/.CR}
MY_P="${PN}-${MY_PV}"
HIBERNATE_P="hibernate-3.2.0.cr4"

DESCRIPTION="Annotations support for Hibernate"
HOMEPAGE="http://annotations.hibernate.org"
SRC_URI="mirror://sourceforge/hibernate/${MY_P}.tar.gz mirror://sourceforge/hibernate/${HIBERNATE_P}.tar.gz"
LICENSE="LGPL-2"
SLOT="3.2"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.5"
RDEPEND=">=virtual/jre-1.5
	=dev-java/hibernate-${SLOT}*
	=dev-java/lucene-1*"

S="${WORKDIR}/${MY_P}"
HIBERNATE_S="${WORKDIR}/hibernate-${SLOT}"

src_unpack() {
	unpack ${A}

	cd ${HIBERNATE_S}/lib
	# start: pulled from hibernate ebuild
	local JAR_PACKAGES="c3p0 commons-collections javassist-3
		commons-logging dom4j-1 ehcache jaxen-1.1 jdbc2-stdext
		log4j oscache proxool swarmcache-1.0 xerces-2 jgroups"
	for PACKAGE in ${JAR_PACKAGES}; do
		java-pkg_jar-from ${PACKAGE}
	done
	java-pkg_jar-from cglib-2.1 cglib.jar

	java-pkg_jar-from jboss-cache jboss-cache.jar
	java-pkg_jar-from jboss-module-common-4 jboss-common.jar
	java-pkg_jar-from jboss-module-j2ee-4 jboss-j2ee.jar
	java-pkg_jar-from jboss-module-jmx-4 jboss-jmx.jar
	java-pkg_jar-from jboss-module-system-4 jboss-system.jar
	java-pkg_jar-from ant-tasks ant-antlr.jar
	java-pkg_jar-from antlr
	java-pkg_jar-from ant-core ant.jar
	java-pkg_jar-from asm-1.5 asm.jar
	java-pkg_jar-from asm-1.5 asm-attrs.jar
	# end: pulled from hibernate ebuild

	java-pkg_jar-from hibernate-${SLOT}

	cd ${S}/lib
	# TODO replace lucene
	# TODO ejb3-persistence.jar
}

src_compile() {
	eant jar $(use_doc)
}

src_install() {
	java-pkg_dojar ${PN}.jar

	use doc && java-pkg_dohtml -r doc/api
	use source && java-pkg_dosrc src/*
}
