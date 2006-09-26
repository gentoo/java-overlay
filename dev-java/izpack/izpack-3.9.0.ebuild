# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

MY_PN="IzPack"
DESCRIPTION="IzPack is an installers generator for the Java platform."
HOMEPAGE="http://www.izforge.com/izpack/"
SRC_URI="http://download.berlios.de/izpack/${MY_PN}.src.${PV}.tar.gz"

#Apache License Version 2.0
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-*"
IUSE=""

CDEPEND=">dev-java/jgoodies-looks-1.2
		dev-java/liquidlnf
		=dev-java/jakarta-regexp-1.3*
		dev-java/kunststoff"
DEPEND=">=virtual/jdk-1.4
		>dev-java-ant-core-1.5"
RDEPEND=">=virtual/jre-1.4"
S=${WORKDIR}

