# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PV="${PV}.GA"
MY_P="${PN//-bin/}-${MY_PV}"
HIBERNATE_P="hibernate-3.2.0.ga"

DESCRIPTION="Annotations support for Hibernate"
HOMEPAGE="http://annotations.hibernate.org"
SRC_URI="mirror://sourceforge/hibernate/${MY_P}.tar.gz mirror://sourceforge/hibernate/${HIBERNATE_P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="3.2"
KEYWORDS="~x86"
IUSE="doc source"

DEPEND=">=virtual/jdk-1.5"
RDEPEND=">=virtual/jre-1.5
	dev-java/antlr
	=dev-java/asm-1.5*
	dev-java/c3p0
	=dev-java/cglib-2.1*
	dev-java/commons-logging
	=dev-java/dom4j-1*
	=dev-java/ehcache-1.2*
	dev-java/jta
	=dev-java/hibernate-${SLOT}*
	=dev-java/javassist-3*
	=dev-java/jaxen-1.1*
	dev-java/jdbc2-stdext
	dev-java/jgroups
	dev-java/log4j
	=dev-java/lucene-1*
	dev-java/oscache
	dev-java/proxool
	=dev-java/swarmcache-1*
	=dev-java/xerces-2*
	=dev-java/hibernate-annotations-${SLOT}*
	"

S="${WORKDIR}/${MY_P}"
HIBERNATE_S="${WORKDIR}/hibernate-${SLOT}"

src_unpack() {
	unpack ${A}

	cd ${HIBERNATE_S}/lib || die "cd failed"
	# start: pulled from hibernate ebuild
	local JAR_PACKAGES="c3p0 commons-collections javassist-3
		commons-logging dom4j-1 jaxen-1.1 jdbc2-stdext jta
		log4j oscache proxool swarmcache-1.0 xerces-2 jgroups"
	for PACKAGE in ${JAR_PACKAGES}; do
		java-pkg_jar-from ${PACKAGE}
	done
	java-pkg_jar-from ehcache-1.2 ehcache.jar
	java-pkg_jar-from cglib-2.1 cglib.jar
	java-pkg_jar-from ant-tasks ant-antlr.jar
	java-pkg_jar-from antlr
	java-pkg_jar-from ant-core ant.jar
	java-pkg_jar-from asm-1.5 asm.jar
	java-pkg_jar-from asm-1.5 asm-attrs.jar
	java-pkg_jar-from hibernate-${SLOT}
	java-pkg_jar-from hibernate-annotations-${SLOT}
}

src_compile() {
	eant jar $(use_doc)
}

src_install() {
	java-pkg_dojar ${PN//-bin/}.jar
	# FIXME: dont use this bundle jar
	java-pkg_dojar ${S}/lib/ejb3-persistence.jar

	use doc && java-pkg_dohtml -r doc/api
	use source && java-pkg_dosrc src/*
}
