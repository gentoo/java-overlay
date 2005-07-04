# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-servers/jboss/jboss-3.2.5.ebuild,v 1.7 2005/04/06 18:12:44 corsair Exp $

#inherit eutils java-pkg jboss-4
inherit jboss-4

MY_P="${P/-common/}-src"
#MODULE="${PN/jboss-/}"
DESCRIPTION="An open source, standards-compliant, J2EE-based application server implemented in 100% Pure Java."
BASE_URL="http://sigmachi.yi.org/~nichoj/projects/java"
#BASE_URL="mirror://gentoo"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
MY_A="${P}-gentoo.tar.bz2 ${MY_A}"
LICENSE="LGPL-2"

HOMEPAGE="http://www.jboss.org"
IUSE="jikes"
KEYWORDS="~x86"

COMMON_DEPEND=" =dev-java/bsf-2.3*
	dev-java/xml-commons-resolver
	dev-java/xalan
	=dev-java/xerces-2*
	=dev-java/commons-beanutils-1.6*
	dev-java/commons-codec
	dev-java/commons-collections
	dev-java/commons-digester
	dev-java/commons-discovery
	dev-java/commons-fileupload
	=dev-java/commons-httpclient-2*
	dev-java/commons-lang
	dev-java/commons-logging
	dev-java/log4j
	dev-java/jakarta-slide-webdavclient
	=dev-java/gnu-regexp-1*
	dev-java/concurrent-util
	=dev-java/dtdparser-1.21*"
DEPEND=">=virtual/jdk-1.3
	dev-java/ant-core
	dev-java/ant-tasks
	dev-java/junit
	${COMMON_DEPEND}
"
RDEPEND=">=virtual/jre-1.3
	${COMMON_DEPEND}"

#INSTALL_DIR=/usr/share/${PN}-${SLOT}

#JBOSS_ROOT="${WORKDIR}/${MY_P}"
S="${JBOSS_ROOT}/${MODULE}"
