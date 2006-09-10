# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit jboss-4

DESCRIPTION="Naming module of JBoss Application Server"
SRC_URI="${BASE_URL}/${P}-gentoo.tar.bz2 ${ECLASS_URI}"
IUSE=""
SLOT="4"
KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="dev-java/junit
	dev-java/log4j
	=dev-java/jboss-module-common-4.0.2*"
DEPEND=">=virtual/jdk-1.4 ${COMMON_DEPEND}"
RDEPEND=">=virtual/jre-1.4 ${COMMON_DEPEND}"

# TODO jikes / 1.5 patch to get change enums
