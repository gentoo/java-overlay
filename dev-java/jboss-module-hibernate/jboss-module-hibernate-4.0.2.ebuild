# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4

DESCRIPTION="Hibernate module of JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
# TODO get jikes to work.
# It mysteriously dies, without any useful errors.
# I suspect this happens when libraries are used that have errors that jikes
# would complain about... so, make sure all dependencies are jikes-capable
IUSE=""
#IUSE="jikes"
SLOT="4"
KEYWORDS="~x86"

COMMON_DEPEND="=dev-java/commons-beanutils-1.6*
	dev-java/commons-codec
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-discovery
	dev-java/commons-fileupload
	=dev-java/commons-httpclient-2*
	=dev-java/commons-lang-2.0*
	dev-java/commons-logging
	dev-java/xalan
	=dev-java/bsf-2.3*
	=dev-java/dom4j-1*
	=dev-java/jaxen-1.1*
	=dev-java/asm-1.5*
	dev-java/odmg
	=dev-java/cglib-2.1*
	=dev-java/jboss-module-cache-${PV}*
	=dev-java/jboss-module-common-${PV}*
	=dev-java/jboss-module-jmx-${PV}*
	=dev-java/jboss-module-j2ee-${PV}*
	=dev-java/jboss-module-server-${PV}*
	=dev-java/jboss-module-system-${PV}*
	=dev-java/jboss-module-transaction-${PV}*"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPEND}"
