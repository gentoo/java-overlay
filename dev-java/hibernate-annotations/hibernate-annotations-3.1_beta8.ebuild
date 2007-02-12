# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2

MY_PV=${PV/_/} # TODO use versionator
MY_P="${PN}-${MY_PV}"
HIBERNATE_P="hibernate-3.1.2"

DESCRIPTION="Annotations support for Hibernate"
HOMEPAGE="http://annotations.hibernate.org"
SRC_URI="mirror://sourceforge/hibernate/${MY_P}.tar.gz mirror://sourceforge/hibernate/${HIBERNATE_P}.tar.gz"
LICENSE="LGPL-2"
SLOT="3.1"
KEYWORDS="~amd64 ~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.5"
RDEPEND=">=virtual/jre-1.5
	=dev-java/hibernate-3.1*
	=dev-java/lucene-1*"

S="${WORKDIR}/${MY_P}"
HIBERNATE_S="${WORKDIR}/hibernate-3.1"

src_unpack() {
	unpack ${A}

	cd ${HIBERNATE_S}/lib
	# start: pulled from hibernate ebuild
	rm *.jar
	local JAR_PACKAGES="asm-2 c3p0 commons-collections
		commons-logging dom4j-1 ehcache jaxen-1.1 jdbc2-stdext
		log4j oscache proxool swarmcache-1.0 xerces-2"
	for PACKAGE in ${JAR_PACKAGES}; do
		java-pkg_jar-from ${PACKAGE}
	done
	java-pkg_jar-from cglib-2.1 cglib.jar

	java-pkg_jar-from jboss-module-cache-4 jboss-cache.jar
	java-pkg_jar-from jboss-module-common-4 jboss-common.jar
	java-pkg_jar-from jboss-module-j2ee-4 jboss-j2ee.jar
	java-pkg_jar-from jboss-module-jmx-4 jboss-jmx.jar
	java-pkg_jar-from jboss-module-system-4 jboss-system.jar
	# end: pulled from hibernate ebuild

	java-pkg_jar-from hibernate-3.1

	cd ${S}/lib
	java-pkg_jar-from lucene-1 lucene.jar lucene-1.4.3.jar
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
