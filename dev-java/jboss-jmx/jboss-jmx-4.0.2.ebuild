# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/jboss/jboss-3.2.5.ebuild,v 1.7 2005/04/06 18:12:44 corsair Exp $

inherit jboss-4

MY_P="${P/-jmx/}-src"

DESCRIPTION="An open source, standards-compliant, J2EE-based application server implemented in 100% Pure Java."
BASE_URL="http://sigmachi.yi.org/~nichoj/projects/java"
#BASE_URL="mirror://gentoo"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
MY_A="${P}-gentoo.tar.bz2 ${MY_A}"
LICENSE="LGPL-2"

HOMEPAGE="http://www.jboss.org"
IUSE="jikes"
SLOT="4"
KEYWORDS="~x86"

COMMON_DEPEND="=dev-java/jboss-common-${PV}*
	dev-java/bcel
	=dev-java/commons-beanutils-1.6*
	dev-java/commons-codec
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-discovery
	dev-java/commons-fileupload
	=dev-java/commons-httpclient-2*
	dev-java/commons-logging
	dev-java/log4j
	dev-java/xalan
	=dev-java/xerces-2*
	=dev-java/dom4j-1*
	=dev-java/jaxen-1.1*
	=dev-java/gnu-regexp-1*
	dev-java/junit
	dev-java/concurrent-util
	=dev-java/crimson-1*
	dev-java/gnu-jaxp
	dev-java/sax"
DEPEND=">=virtual/jdk-1.3
	${COMMON_DEPEND}
"
RDEPEND=">=virtual/jre-1.3
	${COMMON_DEPEND}"

S="${JBOSS_ROOT}/${MODULE}"
